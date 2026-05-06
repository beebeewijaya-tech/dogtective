//
//  JoystickSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit


// MARK: - Joystick business logic
// when pulling joystick based on finger, clamping joystick
extension GameScene {
    func setupJoystick() {
        guard let cam = cam else { return }
        guard let entity = joystickEntity else { return }
        cam.addChild(entity)
    }
    
    func touchJoystick(touch: UITouch) {
        guard let entity = joystickEntity else { return }
        guard let cam = cam else { return }

        let location = touch.location(in: cam)
        if entity.base.contains(location) {
            entity.joystickUI = touch
        }
    }
    
    func moveJoystickKnob(touch: UITouch) {
        guard let entity = joystickEntity else { return }
        guard let cam = cam else { return }
        
        let location = touch.location(in: cam)
        if entity.joystickUI != nil {
            clampingJoystick(entity, location: location)
            movePlayer()
        }
    }
    
    func releaseJoystick() {
        guard let entity = joystickEntity else { return }
        
        entity.joystickUI = nil
        entity.knob.position = entity.base.position
    }
    
    
    func clampingJoystick(_ entity: JoystickEntity, location: CGPoint) {
        // getting gap of finger and joystick base
        let dx = location.x - entity.base.position.x
        let dy = location.y - entity.base.position.y
        let distance = hypot(dx, dy) // get diagonal length gap
    
        
        // if the finger inside the circle follow finger, if outside circle go to max edge
        if distance > entity.maxRadius {
            // if your finger is outside of the joystick circle
            // goal is to get (dx, dy) direction - where your finger at
            // reduce the size / length
            
            let offsetX = (dx / distance) * entity.maxRadius // what is max offset horizontally
            let offsetY = (dy / distance) * entity.maxRadius // what is max offset vertically
            
            // calculate from the base + offset, to get the edge of circle
            entity.knob.position = CGPoint(x: entity.base.position.x + offsetX, y: entity.base.position.y + offsetY)
        } else {
            // if the diagonal gap still inside the circle
            entity.knob.position = location
        }
    }
}
