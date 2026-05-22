//
//  PlayerNode.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit
import GameplayKit

enum PlayerState {
    case idle, moving, chat
}

struct PlayerInfo {
    var texture: SKTexture?
    var coordinates: CGPoint?
    var state: PlayerState?
}


class PlayerEntity: BaseEntity {
    let playerIdleAtlas = SKTextureAtlas(named: "player_idle")
    let playerMoveAtlas = SKTextureAtlas(named: "player_walking")
    let playerSpeed: CGFloat = 0.05 // TODO: tune it

    init() {
        let firstFrame = playerIdleAtlas.textureNamed("mrbones-idle_00") // for first render or default
        let node = SKSpriteNode(texture: firstFrame)
        node.size = CGSize(width: 57, height: 75)
        super.init(node: node)

        // MARK: - shadow & footstep
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 34, height: 12))
        shadow.fillColor = .black
        shadow.strokeColor = .clear
        shadow.alpha = 0.3
        shadow.position = CGPoint(x: 0, y: -node.size.height / 2 + 7)
        shadow.zPosition = -1
        node.addChild(shadow)
        
        if let footsteps = SKEmitterNode(fileNamed: "Footstep") {
            footsteps.name = "footsteps"
            footsteps.position = CGPoint(x: 0, y: -node.size.height / 2 + 4)
            footsteps.zPosition = -2
            footsteps.particleBirthRate = 0
            node.addChild(footsteps)
        }
        
        let playerIdleFrames = (0...61).map { playerIdleAtlas.textureNamed(String(format: "mrbones-idle_%02d", $0))}
        let playerMoveFrames = (0...26).map { playerMoveAtlas.textureNamed(String(format: "mrbones-walking_%02d", $0))}
        let speedScale = self.playerSpeed * 60
        
        // MARK: - prepare components
        addComponent(AnimationComponent(idleFrames: playerIdleFrames, walkingFrames: playerMoveFrames))
        addComponent(MovementComponent(speed: speedScale))
        addComponent(YSortComponent())
    }
    
    
    // MARK: - Make getter for better use rather than to CASTING everytime
    var spriteNode: SKSpriteNode? {
        node as? SKSpriteNode
    }
    
    var animation: AnimationComponent? {
        component(ofType: AnimationComponent.self)
    }
    
    var movement: MovementComponent? {
        component(ofType: MovementComponent.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
