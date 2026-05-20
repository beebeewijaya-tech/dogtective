//
//  EvidenceSystem.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 16/05/26.
//

import SpriteKit
import GameplayKit

extension Notification.Name {
    static let magnifyingButtonTapped  = Notification.Name("magnifyingButtonTapped")
    static let evidenceFromDialog      = Notification.Name("evidenceFromDialog")
    static let dialogDismissedNoReward = Notification.Name("dialogDismissedNoReward")
    static let saveGameRequested       = Notification.Name("saveGameRequested")
}

// Payload keys for `.evidenceFromDialog` userInfo.
enum EvidenceFromDialogKey {
    static let reward           = "reward"           // String
    static let floatingType     = "floatingType"     // EvidenceType
    static let collectedMessage = "collectedMessage" // String (player self-talk)
}

// MARK: - Evidence system
final class EvidenceSystem: GKComponentSystem<EvidenceComponent> {
    weak var scene: SKScene?
    weak var playerEntity: PlayerEntity?
    weak var cam: SKCameraNode?
    
    // MARK: - ViewModel
    weak var dialogStateViewModel: DialogStateViewModel?
    weak var backpackStateViewModel: BackpackStateViewModel?
    weak var gameSettingsViewModel: GameSettingsViewModel?

    private(set) var activeEvidence: EvidenceComponent?
    private var isInteracting = false
    private var lockedForEmptyDialog = false
    private var magnifyObserver: NSObjectProtocol?
    private var dialogObserver: NSObjectProtocol?
    private var dialogDismissObserver: NSObjectProtocol?

    init(scene: SKScene,
         playerEntity: PlayerEntity?,
         cam: SKCameraNode?,
         dialogStateViewModel: DialogStateViewModel?,
         backpackStateViewModel: BackpackStateViewModel?,
         gameSettingsViewModel: GameSettingsViewModel?
    ) {
        self.scene = scene
        self.playerEntity = playerEntity
        self.cam = cam
        self.dialogStateViewModel = dialogStateViewModel
        self.backpackStateViewModel = backpackStateViewModel
        self.gameSettingsViewModel = gameSettingsViewModel
        super.init(componentClass: EvidenceComponent.self)
        subscribe()
    }

    deinit {
        if let obs = magnifyObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        if let obs = dialogObserver {
            NotificationCenter.default.removeObserver(obs)
        }
        if let obs = dialogDismissObserver {
            NotificationCenter.default.removeObserver(obs)
        }
    }

    private func subscribe() {
        magnifyObserver = NotificationCenter.default.addObserver(
            forName: .magnifyingButtonTapped,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleMagnifyingTap()
        }

        dialogObserver = NotificationCenter.default.addObserver(
            forName: .evidenceFromDialog,
            object: nil,
            queue: .main
        ) { [weak self] note in
            self?.handleEvidenceFromDialog(note)
        }

        dialogDismissObserver = NotificationCenter.default.addObserver(
            forName: .dialogDismissedNoReward,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleDialogDismissedNoReward()
        }
    }

    private func handleDialogDismissedNoReward() {
        guard lockedForEmptyDialog else { return } 
        lockedForEmptyDialog = false
        playerEntity?.movement?.isLocked = false
    }

    private func handleEvidenceFromDialog(_ note: Notification) {
        guard !isInteracting else { return }
        let reward = note.userInfo?[EvidenceFromDialogKey.reward] as? String
        let floating = (note.userInfo?[EvidenceFromDialogKey.floatingType] as? EvidenceType)
            ?? .siluet // any safe default
        let collectedMsg = note.userInfo?[EvidenceFromDialogKey.collectedMessage] as? String
        playFoundFlow(reward: reward,
                      floatingType: floating,
                      floatingScale: 0.3) { [weak self] in
            self?.isInteracting = false
            self?.showCollectedMessageOrUnlock(collectedMsg)
        }
    }

    // After a cinematic ends: either show the player's self-talk dialog (and keep movement locked until dismissal), or unlock immediately.
    private func showCollectedMessageOrUnlock(_ message: String?) {
        guard let message = message, !message.isEmpty,
              let vm = dialogStateViewModel else {
            playerEntity?.movement?.isLocked = false
            return
        }
        // Reuse the empty-dialog lock flag — dismissal posts
        // .dialogDismissedNoReward which unlocks.
        lockedForEmptyDialog = true
        vm.setDialog(
            dialog: Dialog(message: message, evidence: false),
            npc: "Mr.Bones",
            npcImage: "mrbones-idle_00"
        )
    }

    // MARK: - Per-frame proximity check
    override func update(deltaTime seconds: TimeInterval) {
        guard !isInteracting else { return }
        guard let playerPos = playerEntity?.node?.position else { return }

        var best: EvidenceComponent?
        var bestDistSq: CGFloat = .greatestFiniteMagnitude

        for comp in components where comp.state != .collected && comp.state != .interacting {
            guard let n = comp.containerNode else { continue }
            let cx = n.position.x + comp.proximityOffset.x
            let cy = n.position.y + comp.proximityOffset.y
            let dx = cx - playerPos.x
            let dy = cy - playerPos.y
            let distSq = dx * dx + dy * dy
            let r = comp.proximityRadius
            if distSq <= r * r && distSq < bestDistSq {
                bestDistSq = distSq
                best = comp
            } else if comp.state == .nearby {
                comp.exitProximity()
            }
        }

        if activeEvidence !== best {
            activeEvidence?.exitProximity()
            activeEvidence = best
            best?.enterProximity()
        } else {
            best?.enterProximity()
        }
    }

    // MARK: - Magnifying tap
    private func handleMagnifyingTap() {
        if let ev = activeEvidence, ev.state == .nearby {
            beginInteraction(ev)
        } else {
            showEmptyMagnifyDialog()
        }
    }

    private func showEmptyMagnifyDialog() {
        guard let vm = dialogStateViewModel else { return }
        // Freeze player so leftover joystick input doesn't slide
        if let movement = playerEntity?.movement, !movement.isLocked {
            movement.velocity = .zero
            playerEntity?.node?.physicsBody?.velocity = .zero
            movement.isLocked = true
            lockedForEmptyDialog = true
        }
        vm.setDialog(
            dialog: Dialog(message: "Sniff... Nothing here", evidence: false),
            npc: "Mr.Bones",
            npcImage: "mrbones-idle_00"
        )
    }

    // MARK: - Interaction flow (ground evidence)
    private func beginInteraction(_ ev: EvidenceComponent) {
        ev.beginInteract()
        playFoundFlow(reward: ev.reward,
                      floatingType: ev.floatingType,
                      floatingScale: ev.floatingScale) { [weak self] in
            self?.finishGroundInteraction(ev: ev)
        }
    }

    private func finishGroundInteraction(ev: EvidenceComponent) {
        ev.endInteract()
        if activeEvidence === ev {
            activeEvidence = nil
        }
        // If this evidence belongs to a reward group, all siblings in the
        // group become inert (no further interaction).
        if let group = ev.rewardGroup {
            inertSiblings(in: group, except: ev)
        }
        if let entity = ev.entity {
            removeComponent(foundIn: entity)
        }
        isInteracting = false
        // Show self-talk if configured; otherwise unlock immediately.
        showCollectedMessageOrUnlock(ev.collectedMessage)
    }

    private func inertSiblings(in group: String, except ev: EvidenceComponent) {
        let siblings = components.filter { $0 !== ev && $0.rewardGroup == group }
        for sibling in siblings {
            sibling.markInert()
            if let entity = sibling.entity {
                removeComponent(foundIn: entity)
            }
        }
    }

    // MARK: - Shared found-flow
    func playFoundFlow(reward: String?,
                       floatingType: EvidenceType,
                       floatingScale: CGFloat,
                       onEnd: @escaping () -> Void) {
        guard let player = playerEntity, let playerNode = player.node else {
            onEnd(); return
        }
        isInteracting = true
        player.movement?.isLocked = true
        dialogStateViewModel?.isCinematic = true
        playerNode.physicsBody?.velocity = .zero

        if let cam = cam {
            cam.removeAction(forKey: "evidence_zoom")
            let zoomIn = SKAction.scale(to: 0.65, duration: 0.29)
            zoomIn.timingMode = .easeOut
            cam.run(zoomIn, withKey: "evidence_zoom")
        }

        spawnFloatingItem(on: playerNode, type: floatingType, scale: floatingScale)

        let foundFrames = loadFrames(
            atlasName: "player_evidence_found",
            prefix: "player_evidence_found",
            maxIndex: 106
        )
        let fallbackDuration: TimeInterval = foundFrames.isEmpty ? 1.2 : 0

        player.animation?.playOnce(frames: foundFrames,
                                   timePerFrame: 1.0/43.0,
                                   scaleMultiplier: 1.05) { [weak self] in
            let endedFrames = self?.loadFrames(
                atlasName: "player_evidence_found_ended",
                prefix: "player_evidence_found_ended",
                maxIndex: 52
            ) ?? []

            let runEnded: () -> Void = { [weak self] in
                // Match zoom-out duration to the ended animation length so
                // they finish together — masks any size snap at the boundary.
                let endedPerFrame: TimeInterval = 1.0/80.0
                let endedDuration = TimeInterval(endedFrames.count) * endedPerFrame
                self?.startZoomOut(duration: endedDuration)
                self?.playerEntity?.animation?.playOnce(frames: endedFrames,
                                                        timePerFrame: endedPerFrame,
                                                        scaleMultiplier: 1.05) { [weak self] in
                    self?.finishCinematic(reward: reward)
                    onEnd()
                }
            }
            if fallbackDuration > 0 {
                self?.scene?.run(.wait(forDuration: fallbackDuration), completion: runEnded)
            } else {
                runEnded()
            }
        }
    }

    private func startZoomOut(duration: TimeInterval = 0.3) {
        guard let cam = cam else { return }
        cam.removeAction(forKey: "evidence_zoom")
        let zoomOut = SKAction.scale(to: 1.0, duration: duration)
        zoomOut.timingMode = .easeInEaseOut
        cam.run(zoomOut, withKey: "evidence_zoom")
    }

    private func finishCinematic(reward: String?) {
        guard let playerNode = playerEntity?.node else { return }
        if let item = playerNode.childNode(withName: "evidence_floating_item") {
            item.run(.sequence([.fadeOut(withDuration: 0.2), .removeFromParent()]))
        }
        backpackStateViewModel?.collect(reward)
        
        // Save to settings
        gameSettingsViewModel?.playerPosition = playerNode.position
        gameSettingsViewModel?.numOfEvidence = backpackStateViewModel?.collectedKeys.count ?? 0
        gameSettingsViewModel?.collectedEvidence = Array(backpackStateViewModel?.collectedKeys ?? [])
        gameSettingsViewModel?.save()
        dialogStateViewModel?.isCinematic = false
    }

    // MARK: - Helpers
    private func spawnFloatingItem(on playerNode: SKNode,
                                   type: EvidenceType,
                                   scale: CGFloat) {
        let texture = SKTexture(imageNamed: type.textureName)
        let natural = texture.size()
        let displaySize = CGSize(width: natural.width * scale,
                                 height: natural.height * scale)
        let item = SKSpriteNode(texture: texture)
        item.size = displaySize
        item.position = CGPoint(x: 0, y: 60)
        item.zPosition = 5000
        item.alpha = 0
        item.name = "evidence_floating_item"

        let glow = SKSpriteNode(texture: texture)
        glow.size = displaySize
        glow.color = .yellow
        glow.colorBlendFactor = 1.0
        glow.alpha = 0.9
        let glowEffect = SKEffectNode()
        glowEffect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 14.0])
        glowEffect.shouldRasterize = true
        glowEffect.blendMode = .add
        glowEffect.zPosition = -1
        glowEffect.addChild(glow)
        item.addChild(glowEffect)

        playerNode.addChild(item)
        item.run(.fadeIn(withDuration: 0.2))

        let pulseUp = SKAction.group([
            .scale(to: 1.15, duration: 0.5),
            .fadeAlpha(to: 1.0, duration: 0.5)
        ])
        let pulseDown = SKAction.group([
            .scale(to: 1.0, duration: 0.5),
            .fadeAlpha(to: 0.85, duration: 0.5)
        ])
        glow.run(.repeatForever(.sequence([pulseUp, pulseDown])))

        let bob = SKAction.sequence([
            .moveBy(x: 0, y: 4, duration: 0.5),
            .moveBy(x: 0, y: -4, duration: 0.5)
        ])
        item.run(.repeatForever(bob))
    }

    private func loadFrames(atlasName: String, prefix: String, maxIndex: Int) -> [SKTexture] {
        let atlas = SKTextureAtlas(named: atlasName)
        let available = Set(atlas.textureNames)
        guard !available.isEmpty else { return [] }
        var frames: [SKTexture] = []
        for i in 0...maxIndex {
            let name = String(format: "\(prefix)_%02d", i)
            if available.contains(name) {
                frames.append(atlas.textureNamed(name))
            }
        }
        return frames
    }
}
