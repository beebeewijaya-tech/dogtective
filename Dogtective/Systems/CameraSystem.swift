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
        cam.position = node.position
    }
}
