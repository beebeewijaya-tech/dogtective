//
//  MovementSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit
import GameplayKit

class MovementSystem: GKComponentSystem<MovementComponent> {
    var joystickEntity: JoystickEntity?
    var playerEntity: PlayerEntity?
    
    init(joystickEntity: JoystickEntity?, playerEntity: PlayerEntity?) {
        self.joystickEntity = joystickEntity
        self.playerEntity = playerEntity
        super.init(componentClass: MovementComponent.self)
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let playerEntity = playerEntity else { return }
        guard let playerNode = playerEntity.spriteNode else { return }
        guard let joystickEntity = joystickEntity else { return }
        
        let dx = joystickEntity.knob.position.x - joystickEntity.base.position.x
        let dy = joystickEntity.knob.position.y - joystickEntity.base.position.y
        
        playerEntity.movement?.velocity = CGVector(dx: dx, dy: dy)
        if dx != 0 || dy != 0 {
            playerNode.xScale = dx > 0 ? 1 : -1
            playerEntity.animation?.playAnimation(state: .moving)
        } else {
            playerEntity.animation?.playAnimation(state: .idle)
        }
        
        playerEntity.update(deltaTime: seconds) // will run the movement
    }
}


// MARK: - Movement System
// implementing the movement of the player
extension GameScene {
    func setMapPosition() {
        guard let playerEntity = playerEntity else { return }
        guard let playerNode = playerEntity.node else { return }

        if playerNode.position.x > 1000 && playerNode.position.y > 1000 {
            minimapStateViewModel?.setState(.park)
        } else if playerNode.position.x > 1000 && playerNode.position.y < 1000 {
            minimapStateViewModel?.setState(.central)
        } else if playerNode.position.x < 1000 && playerNode.position.y > 1000 {
            minimapStateViewModel?.setState(.house)
        } else if playerNode.position.x < 1000 && playerNode.position.y < 1000 {
            minimapStateViewModel?.setState(.police)
        }
    }
}
