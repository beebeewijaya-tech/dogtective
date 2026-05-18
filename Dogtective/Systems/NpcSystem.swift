//
//  NpcSystem.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 17/05/26.
//

import SpriteKit

final class NpcSystem {
    weak var scene: SKScene?
    weak var playerEntity: PlayerEntity?
    weak var dialogStateViewModel: DialogStateViewModel?

    let npcs: [NpcEntity]

    private(set) var activeNpc: NpcEntity?
    private var currentDialogState: DialogState?

    // Optional hook fired when an `evidence: true` dialog is presented.
    var onEvidenceDialogShown: ((Dialog) -> Void)?

    init(scene: SKScene,
         npcs: [NpcEntity],
         playerEntity: PlayerEntity?,
         dialogStateViewModel: DialogStateViewModel?) {
        self.scene = scene
        self.npcs = npcs
        self.playerEntity = playerEntity
        self.dialogStateViewModel = dialogStateViewModel
    }

    func npc(withId id: Int) -> NpcEntity? {
        npcs.first { $0.id == id }
    }

    // MARK: - Setup
    // Adds each NPC's node to the scene + attaches a circular static body
    func setup(register: ((NpcEntity) -> Void)? = nil) {
        guard let scene = scene else { return }
        for npc in npcs {
            guard let node = npc.spriteNode else { continue }
            register?(npc)

            node.position = npc.position
            scene.addChild(node)

            let bodyOffset = CGPoint(x: 0, y: -node.size.height * 0.35)
            node.applyStaticBody(
                shape: .circle(node.size.width * 0.7),
                offset: bodyOffset,
                category: PhysicsCategory.npc,
                collidesWith: PhysicsCategory.player
            )

            npc.animation?.playAnimation(state: .idle)
        }
    }

    // MARK: - Contact callbacks
    func handleContactBegin(_ contact: SKPhysicsContact) {
        guard let vm = dialogStateViewModel else { return }
        let mask = Set([contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask])
        switch mask {
        case [PhysicsCategory.player, PhysicsCategory.npc]:
            let npcBody = contact.bodyA.categoryBitMask == PhysicsCategory.npc
                ? contact.bodyA
                : contact.bodyB
            activeNpc?.animation?.removeBubbleChat()
            activeNpc = npcs.first { $0.node == npcBody.node }
            activeNpc?.animation?.playBubbleChat()
            vm.setState(.bubble)
        default:
            return
        }
    }

    func handleContactEnd(_ contact: SKPhysicsContact) {
        guard let vm = dialogStateViewModel else { return }
        let mask = Set([contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask])
        switch mask {
        case [PhysicsCategory.player, PhysicsCategory.npc]:
            activeNpc?.animation?.removeBubbleChat()
            activeNpc = nil
            vm.setState(.idle)
        default:
            return
        }
    }

    // MARK: - Per-frame dialog state check
    func update() {
        guard let vm = dialogStateViewModel else { return }

        if vm.isChat == .chat {
            guard currentDialogState != .chat else { return }
            currentDialogState = .chat
            let dialog = activeNpc?.dialogComponent?.getDialog()
            vm.dialog = dialog
            vm.npc = activeNpc?.name

            if let dialog = dialog, dialog.evidence {
                onEvidenceDialogShown?(dialog)
            }

            // Once an evidence dialog has fired, remove it so re-talking
            // can't repeat the reward / quest tick.
            activeNpc?.dialogComponent?.removeEvidenceDialog()
        } else {
            currentDialogState = nil
        }
    }
}
