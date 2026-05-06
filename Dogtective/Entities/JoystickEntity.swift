//
//  JoystickEntity.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit

class JoystickEntity: SKNode {
    let base: SKSpriteNode
    let knob: SKSpriteNode
    var maxRadius: CGFloat = 0
    var joystickUI: UITouch!
    var sceneSize: CGSize

    init(sceneSize: CGSize) {
        self.base = SKSpriteNode(imageNamed: "joystick_base")
        self.knob = SKSpriteNode(imageNamed: "joystick_knob")
        self.sceneSize = sceneSize
        
        super.init()
        
        self.setupBase()
        self.setupKnob()
        self.setupRadius()
    }
    
    
    private func setupBase() {
        base.size = CGSize(width: 120, height: 120)
        base.position = CGPoint(x: (-sceneSize.width / 2) + 120, y: (-sceneSize.height / 2) + 100)
        addChild(base)
    }
    
    private func setupKnob() {
        knob.size = CGSize(width: 70, height: 70)
        knob.position = CGPoint(x: (-sceneSize.width / 2) + 120, y: (-sceneSize.height / 2) + 100)
        addChild(knob)
    }
    
    private func setupRadius() {
        maxRadius = base.size.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
