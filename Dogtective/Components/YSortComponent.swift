//
//  YSortComponent.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import SpriteKit
import GameplayKit

// Per-frame y-sort. Sets zPosition based on world Y so lower-Y nodes draw above higher-Y nodes.
class YSortComponent: GKComponent {
    override func update(deltaTime seconds: TimeInterval) {
        guard let entity = entity as? BaseEntity, let node = entity.node else { return }
        node.zPosition = -sortY(for: node)
    }

    // Sort by visual base (feet) so anchor differences don't break ordering.
    private func sortY(for node: SKNode) -> CGFloat {
        if let sprite = node as? SKSpriteNode {
            return sprite.position.y - sprite.size.height * sprite.anchorPoint.y
        }
        return node.position.y
    }
}
