//
//  PhysicsBodyComponent.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import SpriteKit
import GameplayKit

class PhysicsBodyComponent: GKComponent {
    let shape: CollisionShape
    let offset: CGPoint
    let isDynamic: Bool
    let category: UInt32
    let collidesWith: UInt32

    init(shape: CollisionShape,
         offset: CGPoint = .zero,
         isDynamic: Bool,
         category: UInt32,
         collidesWith: UInt32) {
        self.shape = shape
        self.offset = offset
        self.isDynamic = isDynamic
        self.category = category
        self.collidesWith = collidesWith
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //  Attach the configured body to a target node (usually the bottom sprite).
    func attach(to node: SKNode) {
        if isDynamic {
            CollisionSystem.applyDynamicBody(
                to: node,
                shape: shape,
                offset: offset,
                category: category,
                collidesWith: collidesWith
            )
        } else {
            CollisionSystem.applyStaticBody(
                to: node,
                shape: shape,
                offset: offset,
                category: category,
                collidesWith: collidesWith
            )
        }
    }
}
