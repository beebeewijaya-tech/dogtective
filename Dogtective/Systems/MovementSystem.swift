//
//  MovementSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit


// MARK: - Movement System
// implementing the movement of the player
extension GameScene {
    func movePlayer() {
        guard let playerEntity = playerEntity else { return }
        guard let joystickEntity = joystickEntity else { return }
        
        let dx = joystickEntity.knob.position.x - joystickEntity.base.position.x
        let dy = joystickEntity.knob.position.y - joystickEntity.base.position.y
        
        playerEntity.position.x += dx * playerEntity.playerSpeed
        playerEntity.position.y += dy * playerEntity.playerSpeed
        
        cameraFollowPlayer()
    }
}
