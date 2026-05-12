//
//  MovementComponent.swift
//  Dogtective
//
//  Created by Bee Wijaya on 12/05/26.
//

import GameplayKit

class MovementComponent: GKComponent {
    var speed: CGFloat
    var velocity: CGVector = .zero
    
    init(speed: CGFloat) {
        self.speed = speed
        self.velocity = .zero
        super.init()
    }
    
    var node: SKNode? {
        entity?.component(ofType: GKSKNodeComponent.self)?.node as? SKNode
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        guard let node = node else { return }
        node.physicsBody?.velocity = CGVector(dx: velocity.dx * speed, dy: velocity.dy * speed)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
