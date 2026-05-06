//
//  PlayerSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 05/05/26.
//

import SpriteKit

// MARK: - Player System
// business logic regarding player, location, animation
extension GameScene {
    func setupPlayer() {
        guard let entity = playerEntity else { return }
        
        let width = entity.playerIdleFrames.first?.size().width ?? 0
        let height = entity.playerIdleFrames.first?.size().height ?? 0

        entity.position = CGPoint(x: size.width / 2, y: size.height / 2)
        entity.size = CGSize(width: width, height: height)
        addChild(entity)
        
        entity.idlePlayerState()
        
        cameraFollowPlayer()
    }
}
