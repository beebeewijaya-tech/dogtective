//
//  JoystickComponent.swift
//  Dogtective
//
//  Created by Bee Wijaya on 12/05/26.
//

import GameplayKit

class JoystickComponent: GKComponent {
    private var joystickEntity: JoystickEntity? { entity as? JoystickEntity }
    private var maxRadius: CGFloat = 0
    
    init(maxRadius: CGFloat) {
        self.maxRadius = maxRadius
        super.init()
    }
    
    func release() {
        guard let joystickEntity = joystickEntity else { return }
        joystickEntity.knob.position = joystickEntity.base.position
    }
    
    func clampingJoystick(location: CGPoint) {
        guard let joystickEntity = joystickEntity else { return }

        
        // getting gap of finger and joystick base
        let dx = location.x - joystickEntity.base.position.x
        let dy = location.y - joystickEntity.base.position.y
        let distance = hypot(dx, dy) // get diagonal length gap
    
        
        // if the finger inside the circle follow finger, if outside circle go to max edge
        if distance > maxRadius {
            // if your finger is outside of the joystick circle
            // goal is to get (dx, dy) direction - where your finger at
            // reduce the size / length
            
            let offsetX = (dx / distance) * maxRadius // what is max offset horizontally
            let offsetY = (dy / distance) * maxRadius // what is max offset vertically
            
            // calculate from the base + offset, to get the edge of circle
            joystickEntity.knob.position = CGPoint(x: joystickEntity.base.position.x + offsetX, y: joystickEntity.base.position.y + offsetY)
        } else {
            // if the diagonal gap still inside the circle
            joystickEntity.knob.position = location
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
