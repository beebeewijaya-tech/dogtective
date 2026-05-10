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

        entity.position = foodStallPosition.first!
        entity.size = CGSize(width: width, height: height)
        addChild(entity)

        // Player physics body 
        let bodyWidth = width * 0.4
        let bodyHeight = height * 0.2
        let bodyOffset = CGPoint(x: 0, y: -height * 0.35)
        CollisionSystem.applyDynamicBody(
            to: entity,
            shape: .rectangle(CGSize(width: bodyWidth, height: bodyHeight)),
            offset: bodyOffset
        )

        entity.idlePlayerState()

        cameraFollowPlayer()
    }
}
