//
//  NpcEntity.swift
//  Dogtective
//
//  Created by Bee Wijaya on 12/05/26.
//

import GameplayKit

enum NpcType {
    case police, npc
    
    var name: String {
        switch self {
        case .police:
            return "police"
        case .npc:
            return "npc"
        }
    }
}

class NpcEntity: BaseEntity {
    var npcIdleAtlas: SKTextureAtlas
    var position: CGPoint
    
    init(id: Int, type: NpcType, position: CGPoint) {
        self.npcIdleAtlas = SKTextureAtlas(named: "\(type.name)_\(id)_idle")
        self.position = position
        
        let node = SKSpriteNode(texture: npcIdleAtlas.textureNamed("\(type.name)\(id)-idle_00"))
        node.size = CGSize(width: 57, height: 75)
        super.init(node: node)
        
        let npcIdleTextures = (0...59).map { i in
            let textureName = String(format: "\(type.name)\(id)-idle_%02d", i)
            return self.npcIdleAtlas.textureNamed(textureName)
        }
        
        // MARK: - prepare components
        addComponent(AnimationComponent(idleFrames: npcIdleTextures, walkingFrames: []))
    }
    
    // MARK: - Make getter for better use rather than to CASTING everytime

    var spriteNode: SKSpriteNode? {
        node as? SKSpriteNode
    }
    
    var animation: AnimationComponent? {
        component(ofType: AnimationComponent.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
