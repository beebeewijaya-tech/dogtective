//
//  EvidenceComponent.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 16/05/26.
//

import SpriteKit
import GameplayKit

// MARK: - Evidence types
enum EvidenceType {
    case corn
    case pieceOfCorn
    case fur
    case tissue
    case dig
    case digBones
    case digRaw
    case digTissue
    case brokenFence
    case siluet
    case trashBinOpened
    case trashBin
    case billy

    var textureName: String {
        switch self {
        case .corn:         return "corn"
        case .pieceOfCorn:  return "piece_of_corn"
        case .fur:          return "fur"
        case .tissue:       return "tissue"
        case .dig:          return "dig"
        case .digBones:     return "dig_bones"
        case .digRaw:       return "dig_raw"
        case .digTissue:    return "dig_tissue"
        case .brokenFence:  return "broken_fence"
        case .siluet:       return "siluet"
        case .trashBinOpened:   return "trash_bin_opened"
        case .trashBin:         return "trash_bin"
        case .billy:         return "billy"
        }
    }

    var displayName: String {
        switch self {
        case .corn:         return "Corn"
        case .pieceOfCorn:  return "Piece of Corn"
        case .fur:          return "Fur"
        case .tissue:       return "Tissue"
        case .dig:          return "Dig Mark"
        case .digBones:     return "Bone Fragments"
        case .digRaw:       return "Raw Meat"
        case .digTissue:    return "Tissue Sample"
        case .brokenFence:  return "Broken Fence"
        case .siluet:       return "Culprit Shadow"
        case .trashBinOpened: return "Trash Bin Opened"
        case .trashBin:         return "Trash Bin"
        case .billy:         return "Billy"
        }
    }

    // Default backpack item key when this evidence is collected.
    var defaultBackpackKey: String? {
        switch self {
        case .corn, .trashBinOpened, .trashBin:         return "corn"
        case .pieceOfCorn:  return "piece_of_corn"
        case .fur:          return "fur"
        case .tissue:       return "tissue"
        case .dig:          return "dig"
        case .brokenFence:  return "fence"
        case .siluet:       return "siluet"
        case .billy:         return "billy"
        case .digRaw, .digBones, .digTissue: return nil
        }
    }

    var defaultBehavior: PostInteractionBehavior {
        switch self {
        case .digRaw: return .persistAs(.dig, size: nil)
        default:      return .remove
        }
    }
}

// MARK: - What happens after interaction completes
enum PostInteractionBehavior {
    case remove
    case persistAs(EvidenceType, size: CGSize? = nil)
}

// MARK: - State
enum EvidenceState {
    case idle
    case nearby
    case interacting
    case collected
}

// MARK: - Config
struct EvidenceConfig {
    let type: EvidenceType
    let position: CGPoint
    var scale: CGFloat = 0.33
    var proximityRadius: CGFloat = 80
    // Shifts the proximity circle's center relative to the evidence's position.
    // Use to bias where the player must stand to interact — e.g. (+y) to force
    // interaction from above (the fence reachable only from inside the yard).
    var proximityOffset: CGPoint = .zero
    var collisionSize: CGSize? = nil
    var collisionOffset: CGPoint = .zero
    // Backpack item key awarded
    var reward: String? = nil
    // What to do after interaction completes.
    var behavior: PostInteractionBehavior? = nil
    // Texture shown floating above player's head
    var floatingType: EvidenceType? = nil
    // Scale applied to the floating texture (relative to its own size).
    var floatingScale: CGFloat = 0.28
    // Items sharing the same non-nil group are mutually exclusive. The first one collected makes all others in the group inert
    var rewardGroup: String? = nil
    // Player self-talk shown after the cinematic. e.g. "Tissue, hmm this must be interesting".
    // Speaker is "Mr.Bones". nil = no follow-up dialog.
    var collectedMessage: String? = nil
    // When true, the ground sprite stays visible during the cinematic
    var keepGroundVisible: Bool = false
    // YSort tiebreak when two evidence/obstacles overlap at the same feet-Y.
    // Positive draws in front. Matches ObstacleConfig.zOffset semantics.
    var zOffset: CGFloat = 0
    var id: Int = 0
}

extension EvidenceConfig {
    static func item(_ type: EvidenceType,
                     at position: CGPoint,
                     scale: CGFloat = 0.33,
                     proximityRadius: CGFloat = 45,
                     proximityOffset: CGPoint = .zero,
                     floatingType: EvidenceType? = nil,
                     floatingScale: CGFloat = 0.3,
                     rewardGroup: String? = nil,
                     collectedMessage: String? = nil,
                     zOffset: CGFloat = 0) -> EvidenceConfig {
        EvidenceConfig(type: type,
                       position: position,
                       scale: scale,
                       proximityRadius: proximityRadius,
                       proximityOffset: proximityOffset,
                       floatingType: floatingType,
                       floatingScale: floatingScale,
                       rewardGroup: rewardGroup,
                       collectedMessage: collectedMessage,
                       zOffset: zOffset)
    }

    // dig_raw that awards 'tissue' to backpack, then turns into a plain dig spot.
    static func digRawTissue(at position: CGPoint,
                             scale: CGFloat = 0.33,
                             proximityRadius: CGFloat = 80,
                             floatingScale: CGFloat = 0.12,
                             rewardGroup: String? = nil,
                             collectedMessage: String? = nil) -> EvidenceConfig {
        EvidenceConfig(type: .digRaw,
                       position: position,
                       scale: scale,
                       proximityRadius: proximityRadius,
                       reward: "tissue",
                       behavior: .persistAs(.dig),
                       floatingType: .tissue,
                       floatingScale: floatingScale,
                       rewardGroup: rewardGroup,
                       collectedMessage: collectedMessage,
                       keepGroundVisible: true)
    }

    // dig_raw that awards 'dig' to backpack, then turns into a plain dig spot.
    static func digRawDig(at position: CGPoint,
                          scale: CGFloat = 0.33,
                          proximityRadius: CGFloat = 80,
                          floatingScale: CGFloat = 0.2,
                          rewardGroup: String? = nil,
                          collectedMessage: String? = nil) -> EvidenceConfig {
        EvidenceConfig(type: .digRaw,
                       position: position,
                       scale: scale,
                       proximityRadius: proximityRadius,
                       reward: "dig",
                       behavior: .persistAs(.dig),
                       floatingType: .dig,
                       floatingScale: floatingScale,
                       rewardGroup: rewardGroup,
                       collectedMessage: collectedMessage,
                       keepGroundVisible: true)
    }
    
    static func trashCan (at position: CGPoint,
                          scale: CGFloat = 0.3,
                          proximityRadius: CGFloat = 80,
                          floatingScale: CGFloat = 0.2,
                          rewardGroup: String? = nil,
                          collectedMessage: String? = nil) -> EvidenceConfig {
        EvidenceConfig(type: .trashBin,
                       position: position,
                       scale: scale,
                       proximityRadius: proximityRadius,
                       reward: "corn",
                       behavior: .persistAs(.trashBinOpened, size: CGSize(width: 56, height:43)),
                       floatingType: .corn,
                       floatingScale: floatingScale,
                       rewardGroup: rewardGroup,
                       collectedMessage: collectedMessage,
                       keepGroundVisible: true)
    }
}

// MARK: - Component
final class EvidenceComponent: GKComponent {
    let type: EvidenceType
    let proximityRadius: CGFloat
    let proximityOffset: CGPoint
    let scale: CGFloat
    let reward: String?
    let behavior: PostInteractionBehavior
    let floatingType: EvidenceType
    let floatingScale: CGFloat
    let rewardGroup: String?
    let collectedMessage: String?
    let keepGroundVisible: Bool

    private(set) var state: EvidenceState = .idle

    let mainSprite: SKSpriteNode
    let glowNode: SKEffectNode
    let glowSprite: SKSpriteNode

    private let floatActionKey = "evidence_float"
    private let glowActionKey  = "evidence_glow"

    init(config: EvidenceConfig) {
        self.type = config.type
        self.proximityRadius = config.proximityRadius
        self.proximityOffset = config.proximityOffset
        self.scale = config.scale
        self.reward = config.reward ?? config.type.defaultBackpackKey
        self.behavior = config.behavior ?? config.type.defaultBehavior
        self.floatingType = config.floatingType ?? config.type
        self.floatingScale = config.floatingScale
        self.rewardGroup = config.rewardGroup
        self.collectedMessage = config.collectedMessage
        self.keepGroundVisible = config.keepGroundVisible

        let texture = SKTexture(imageNamed: config.type.textureName)
        let size = CGSize(
            width: texture.size().width * config.scale,
            height: texture.size().height * config.scale
        )

        let glow = SKSpriteNode(texture: texture)
        glow.size = size
        glow.color = .yellow
        glow.colorBlendFactor = 1.0
        glow.alpha = 0.0

        let effect = SKEffectNode()
        effect.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10.0])
        effect.shouldRasterize = true
        effect.shouldEnableEffects = true
        effect.blendMode = .add
        effect.zPosition = -1
        effect.addChild(glow)

        let main = SKSpriteNode(texture: texture)
        main.size = size
        main.zPosition = 0

        self.mainSprite = main
        self.glowNode = effect
        self.glowSprite = glow

        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    var containerNode: SKNode? {
        entity?.component(ofType: GKSKNodeComponent.self)?.node
    }

    func attach(to container: SKNode) {
        container.addChild(glowNode)
        container.addChild(mainSprite)
    }

    // MARK: Transitions
    func enterProximity() {
        guard state == .idle else { return }
        state = .nearby
        startFloatAndGlow()
    }

    func exitProximity() {
        guard state == .nearby else { return }
        state = .idle
        stopFloatAndGlow()
    }

    func beginInteract() {
        guard state == .nearby else { return }
        state = .interacting
        stopFloatAndGlow()
        if !keepGroundVisible {
            containerNode?.run(.fadeOut(withDuration: 0.15))
        }
    }

    func endInteract() {
        guard state == .interacting else { return }
        state = .collected
        switch behavior {
        case .remove:
            containerNode?.removeFromParent()
        case .persistAs(let newType, let size):
            transform(into: newType, overrideSize: size)
        }
    }

    func markInert() {
        guard state == .idle || state == .nearby else { return }
        stopFloatAndGlow()
        state = .collected
        switch behavior {
        case .remove:
            containerNode?.removeFromParent()
        case .persistAs(let newType, let size):
            transform(into: newType, overrideSize: size)
        }
    }

    // Swap visuals to a different evidence type and leave on map as a non-interactable marker (state stays `.collected`).
    private func transform(into newType: EvidenceType, overrideSize: CGSize?) {
        let texture = SKTexture(imageNamed: newType.textureName)
        mainSprite.texture = texture
        mainSprite.size = overrideSize ?? mainSprite.size
        glowNode.removeFromParent()
        if !keepGroundVisible {
            containerNode?.run(.fadeIn(withDuration: 0.2))
        }
    }

    // MARK: Visuals
    private func startFloatAndGlow() {
        let up = SKAction.moveBy(x: 0, y: 4, duration: 0.6)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        mainSprite.run(.repeatForever(.sequence([up, down])), withKey: floatActionKey)
        glowNode.run(.repeatForever(.sequence([up, down])), withKey: floatActionKey)

        let fadeIn  = SKAction.fadeAlpha(to: 0.8, duration: 0.5)
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        glowSprite.run(.repeatForever(.sequence([fadeIn, fadeOut])), withKey: glowActionKey)
    }

    private func stopFloatAndGlow() {
        mainSprite.removeAction(forKey: floatActionKey)
        glowNode.removeAction(forKey: floatActionKey)
        glowSprite.removeAction(forKey: glowActionKey)
        mainSprite.position = .zero
        glowNode.position = .zero
        glowSprite.alpha = 0
    }
}
