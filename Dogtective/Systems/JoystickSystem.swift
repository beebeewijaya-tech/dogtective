//
//  JoystickSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit
import GameplayKit

class JoystickSystem: GKComponentSystem<JoystickComponent> {
    var cam: SKCameraNode?
    var joystickEntity: JoystickEntity?
    weak var scene: SKScene?
    
    init(joystickEntity: JoystickEntity?, cam: SKCameraNode? = nil, scene: SKScene? = nil) {
        self.cam = cam
        self.scene = scene
        self.joystickEntity = joystickEntity
        super.init(componentClass: JoystickComponent.self)
    }
    
    private func location(for touch: UITouch) -> CGPoint {
        if let cam = cam { return touch.location(in: cam) }
        if let node = joystickEntity?.node { return touch.location(in: node) }
        return .zero
    }
    
    func touchJoystick(touch: UITouch) {
        guard let joystickEntity = joystickEntity else { return }
        
        let location = location(for: touch)
        if joystickEntity.base.contains(location) {
            joystickEntity.joystickUI = touch
        }
    }
    
    func moveJoystickKnob(touch: UITouch) {
        guard let joystickEntity = joystickEntity else { return }
        let location = location(for: touch)
        if joystickEntity.joystickUI != nil {
            joystickEntity.joystickComponent?.clampingJoystick(location: location)
        }
    }
    
    func releaseJoystick() {
        guard let joystickEntity = joystickEntity else { return }
        joystickEntity.joystickUI = nil
        joystickEntity.joystickComponent?.release()
    }
    
    func setupJoystick() {
        guard let joystickEntity = joystickEntity else { return }
        guard let node = joystickEntity.node else { return }
        
        if let cam = cam {
            cam.addChild(node)
        } else {
            guard let scene = scene else { return }
            node.position = CGPoint(x: scene.size.width / 2, y: scene.size.height / 2)
            scene.addChild(node)
        }
    }
}
