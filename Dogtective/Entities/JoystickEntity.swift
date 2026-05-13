//
//  JoystickEntity.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import GameplayKit

class JoystickEntity: BaseEntity {
    let base: SKSpriteNode
    let knob: SKSpriteNode
    let sceneSize: CGSize
    var maxRadius: CGFloat = 0
    var joystickUI: UITouch?
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        self.base = SKSpriteNode(imageNamed: "joystick_base")
        self.knob = SKSpriteNode(imageNamed: "joystick_knob")

        let node = SKNode()
        node.addChild(self.base)
        node.addChild(self.knob)
        
        super.init(node: node)
        self.setupBase()
        self.setupKnob()
        self.setupRadius()
        
        // MARK: - Prepare component
        addComponent(JoystickComponent(maxRadius: maxRadius))
    }
    
    // MARK: - Getter func for not always casting
    var joystickComponent: JoystickComponent? {
        component(ofType: JoystickComponent.self)
    }
    
    
    // MARK: - preparing the joystick UI
    private func setupBase() {
        base.size = CGSize(width: 120, height: 120)
        base.position = CGPoint(x: (-sceneSize.width / 2) + 120, y: (-sceneSize.height / 2) + 100)
    }

    private func setupKnob() {
        knob.size = CGSize(width: 70, height: 70)
        knob.position = CGPoint(x: (-sceneSize.width / 2) + 120, y: (-sceneSize.height / 2) + 100)
    }

    private func setupRadius() {
        self.maxRadius = base.size.width / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
