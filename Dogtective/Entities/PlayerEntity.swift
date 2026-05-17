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
        node.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        super.init(node: node)
        
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
