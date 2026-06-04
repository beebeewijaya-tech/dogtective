//
//  YSortComponent.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import SpriteKit
import GameplayKit

// Per-frame y-sort. Sets zPosition based on world Y so lower-Y nodes draw above higher-Y nodes.
// `zOffset` lets overlapping entities (e.g. two trees at same Y) have a deterministic order.
class YSortComponent: GKComponent {
    var zOffset: CGFloat
    var yOffset: CGFloat

    init(zOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        self.zOffset = zOffset
        self.yOffset = yOffset
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update(deltaTime seconds: TimeInterval) {
        guard let entity = entity as? BaseEntity, let node = entity.node else { return }
        node.zPosition = -sortY(for: node) + zOffset
    }

    // Sort by visual base (feet) so anchor differences don't break ordering.
    private func sortY(for node: SKNode) -> CGFloat {
        if let sprite = node as? SKSpriteNode {
            return sprite.position.y - sprite.size.height * sprite.anchorPoint.y
        }
        return node.position.y - yOffset
    }
}
