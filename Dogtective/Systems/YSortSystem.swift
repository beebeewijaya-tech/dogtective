//
//  YSortSystem.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 10/05/26.
//

import SpriteKit

struct YSortSystem {
    // Set zPosition based on world Y so lower-Y nodes draw above higher-Y nodes. Use for nodes that share the gameplay plane (player, tree bottoms, NPCs, dll).
    static func apply(to nodes: [SKNode], offset: CGFloat = 0) {
        for node in nodes {
            node.zPosition = -sortY(for: node) + offset
        }
    }

    // Sort by visual base (feet) so anchor differences don't break ordering.
    private static func sortY(for node: SKNode) -> CGFloat {
        if let sprite = node as? SKSpriteNode {
            return sprite.position.y - sprite.size.height * sprite.anchorPoint.y
        }
        return node.position.y
    }
}
