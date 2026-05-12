//
//  CollisionSystem.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 10/05/26.
//

import SpriteKit

// phyics for the all sprite, for now tree using "obstacle"
// TODO: separate the obstacle to "tree", "lamp", etc or another approached
enum PhysicsCategory {
    static let none: UInt32 = 0
    static let player: UInt32 = 1 << 0
    static let obstacle: UInt32 = 1 << 1
}

enum CollisionShape {
    case rectangle(CGSize)
    case circle(CGFloat)
}

extension SKNode {
    func applyStaticBody(
        shape: CollisionShape,
        offset: CGPoint = .zero,
        category: UInt32 = PhysicsCategory.obstacle,
        collidesWith: UInt32 = PhysicsCategory.player
    ) {
        let body = makeBody(shape: shape, offset: offset)
        body.isDynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        body.friction = 0
        body.restitution = 0
        body.categoryBitMask = category
        body.collisionBitMask = collidesWith
        body.contactTestBitMask = collidesWith
        self.physicsBody = body
    }

    func applyDynamicBody(
        shape: CollisionShape,
        offset: CGPoint = .zero,
        category: UInt32 = PhysicsCategory.player,
        collidesWith: UInt32 = PhysicsCategory.obstacle
    ) {
        let body = makeBody(shape: shape, offset: offset)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.linearDamping = 1.0
        body.friction = 0
        body.restitution = 0
        body.categoryBitMask = category
        body.collisionBitMask = collidesWith
        body.contactTestBitMask = collidesWith
        self.physicsBody = body
    }

    private func makeBody(shape: CollisionShape, offset: CGPoint) -> SKPhysicsBody {
        switch shape {
        case .rectangle(let size):
            return SKPhysicsBody(rectangleOf: size, center: offset)
        case .circle(let radius):
            return SKPhysicsBody(circleOfRadius: radius, center: offset)
        }
    }
}
