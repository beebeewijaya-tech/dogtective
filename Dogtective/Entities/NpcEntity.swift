//
//  NpcEntity.swift
//  Dogtective
//
//  Created by Bee Wijaya on 12/05/26.
//

import GameplayKit

enum NpcType {
    case police, npc, npcKid

    var name: String {
        switch self {
        case .police: return "police"
        case .npc:    return "npc"
        case .npcKid: return "npckid"
        }
    }

    /// Types like `.npcKid` have only one variant — no id segment in asset names.
    var hasIdInAssets: Bool {
        switch self {
        case .npcKid: return false
        default:      return true
        }
    }

    func atlasName(id: Int) -> String {
        hasIdInAssets ? "\(name)_\(id)_idle" : "\(name)_idle"
    }

    func framePrefix(id: Int) -> String {
        hasIdInAssets ? "\(name)\(id)-idle" : "\(name)-idle"
    }
}

class NpcEntity: BaseEntity {
    var name: String
    var npcIdleAtlas: SKTextureAtlas
    var position: CGPoint
    var dialog: [Dialog]
    
    
    // MARK: - atlas
    let bubbleAtlas = SKTextureAtlas(named: "icon_bubble")
    
    init(id: Int = 0, name: String, type: NpcType, position: CGPoint, dialog: [Dialog]) {
        let atlasName = type.atlasName(id: id)
        let framePrefix = type.framePrefix(id: id)

        self.npcIdleAtlas = SKTextureAtlas(named: atlasName)
        self.position = position
        self.dialog = dialog
        self.name = name

        let node = SKSpriteNode(texture: npcIdleAtlas.textureNamed("\(framePrefix)_00"))
        node.size = CGSize(width: 57, height: 75)

        // chat bubble node
        let bubbleNode = SKSpriteNode(texture: bubbleAtlas.textureNamed("icon-bubble_00"))
        bubbleNode.size = CGSize(width: 70, height: 40  )
        bubbleNode.name = "bubble"
        bubbleNode.isHidden = true
        bubbleNode.zPosition = 10000

        node.addChild(bubbleNode)
        super.init(node: node)

        let npcIdleTextures = (0...59).map { i in
            let textureName = String(format: "\(framePrefix)_%02d", i)
            return self.npcIdleAtlas.textureNamed(textureName)
        }
        
        let bubbleTextures = (0...59).map { i in
            let textureName = String(format: "icon-bubble_%02d", i)
            return self.bubbleAtlas.textureNamed(textureName)
        }
        
        // MARK: - prepare components
        addComponent(AnimationComponent(idleFrames: npcIdleTextures, walkingFrames: [], bubbleFrames: bubbleTextures))
        addComponent(DialogComponent(dialog: dialog))
    }
    
    // MARK: - Make getter for better use rather than to CASTING everytime

    var spriteNode: SKSpriteNode? {
        node as? SKSpriteNode
    }
    
    var animation: AnimationComponent? {
        component(ofType: AnimationComponent.self)
    }
    
    var dialogComponent: DialogComponent? {
        component(ofType: DialogComponent.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
