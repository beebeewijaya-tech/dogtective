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

        // Locked during cutscene-like flows
        if playerEntity.movement?.isLocked == true {
            playerEntity.movement?.velocity = .zero
            playerNode.physicsBody?.velocity = .zero
            // Only force idle if a one-shot anim isn't already playing
            if playerEntity.animation?.isPlayingOneShot != true {
                playerEntity.animation?.playAnimation(state: .idle)
            }
            return
        }

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

        let next: MinimapState
        if playerNode.position.x > 458 && playerNode.position.y > 159 {
            next = .park
        } else if playerNode.position.x > 458 {
            next = .central
        } else if playerNode.position.y > 159 {
            next = .house
        } else {
            next = .police
        }

        if minimapStateViewModel?.state != next {
            minimapStateViewModel?.setState(next)
        }
    }
}
