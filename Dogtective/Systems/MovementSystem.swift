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
        
        if dx != 0 || dy != 0 {
            if dx > 0 {
                playerEntity.xScale = 1
            } else {
                playerEntity.xScale = -1
            }
            
             if playerEntity.playerInfo?.state != .moving {
                 playerEntity.removeAllActions()
                 playerEntity.movingPlayerState()
             }
         } else {
             if playerEntity.playerInfo?.state != .idle {
                 playerEntity.removeAllActions()
                 playerEntity.idlePlayerState()
             }
         }
        
        cameraFollowPlayer()
    }
}
