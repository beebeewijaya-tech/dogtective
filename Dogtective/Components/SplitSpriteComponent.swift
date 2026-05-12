//
//  SplitSpriteComponent.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import SpriteKit
import GameplayKit

/// Holds the two sprite pieces produced by SpriteSplitter. `first` and `second` are axis-agnostic:
/// vertical → first = bottom, second = top. Horizontal → first = left, second = right.
class SplitSpriteComponent: GKComponent {
    let first: SKSpriteNode
    let second: SKSpriteNode

    init(first: SKSpriteNode, second: SKSpriteNode) {
        self.first = first
        self.second = second
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
