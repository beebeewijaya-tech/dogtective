//
//  ColliderEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 13/05/26.
//

import Foundation
import GameplayKit

struct ColliderConfig {
    let position : CGPoint
    let shape : CollisionShape
    let offset : CGPoint
}

extension ColliderConfig {
    static func rect(at position: CGPoint, size: CGSize, offset: CGPoint = .zero) -> ColliderConfig {
        ColliderConfig(position: position, shape: .rectangle(size), offset: offset)
    }
    
    static func circle(at position: CGPoint, radius: CGFloat, offset: CGPoint = .zero) -> ColliderConfig {
        ColliderConfig(position: position, shape: .circle(radius), offset: offset)
    }
}

class ColliderEntity: BaseEntity {
    init(config: ColliderConfig) {
        let node = SKNode()
        node.position = config.position
        super.init(node: node)
        
        let body = PhysicsBodyComponent(
            shape: config.shape,
            offset: config.offset,
            isDynamic: false,
            category: PhysicsCategory.obstacle,
            collidesWith: PhysicsCategory.player
        )
        
        addComponent(body)
        body.attach(to: node)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError() }
}

