//
//  CameraSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit

// MARK: - Camera business logic
extension GameScene {
    func setupCamera() {
        cam = SKCameraNode()
        camera = cam
        
        addChild(cam!)
    }
    
    func cameraFollowPlayer() {
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.node else { return }
        guard let cam = cam else { return }
        guard let registry = chunkManager?.registry else {
            cam.position = node.position
            return
        }
        
        let screenHalfWidth = (size.width / 2) * cam.xScale
        let screenHalfHeight = (size.height / 2) * cam.yScale
        
        // camera is at coordinate (0, 0) at middle of the screen
        let mapLeftEdge = registry.mapOriginBottomLeft.x
        let mapRightEdge = mapLeftEdge + registry.mapSize.width
        let mapBottomEdge = registry.mapOriginBottomLeft.y
        let mapTopEdge = mapBottomEdge + registry.mapSize.height
        
        let cameraMinX = mapLeftEdge + screenHalfWidth // how far left "x" can the camera go before showing black
        let cameraMaxX = mapRightEdge - screenHalfWidth // how far right "x" can the camera go before showing black
        let cameraMinY = mapBottomEdge + screenHalfHeight // how far bottom "y" can the camera go
        let cameraMaxY = mapTopEdge - screenHalfHeight // how far top "y" can camera go
        
        // so we will clamp it
        // if the player go to left like a lot, camera will stay at cameraMinX ( maximum )
        // if the player go to right like a lot, camera will stay at cameraMaxX ( maximum )
        let scale = view?.contentScaleFactor ?? 1
        func snapToPixel(_ value: CGFloat) -> CGFloat {
            scale > 0 ? (value * scale).rounded() / scale : value
        }
        let clampedX = min(max(node.position.x, cameraMinX), cameraMaxX) // if player is too far left ( almost black area ), choose cameraMinX,
        let clampedY = min(max(node.position.y, cameraMinY), cameraMaxY)
        cam.position = CGPoint(x: snapToPixel(clampedX), y: snapToPixel(clampedY))
        
        playerEntity.node?.position = CGPoint(
            x: min(max(node.position.x, mapLeftEdge), mapRightEdge), // player will clamp to use mapLeftEdge if it try to go past the value
            y: min(max(node.position.y, mapBottomEdge), mapTopEdge)
        )
    }
}
