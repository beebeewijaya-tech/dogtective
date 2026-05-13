//
//  SpriteSplitter.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 10/05/26.
//

import SpriteKit

enum SplitAxis {
    case vertical    // first = bottom, second = top
    case horizontal  // first = left, second = right
}

struct SpriteSplitter {
    /// Split a texture into two SKSpriteNodes by ratio along an axis.
    /// `ratio` 0..1 = portion belonging to the `first` sprite.
    /// Vertical: first sprite anchor (0.5, 0), second sits above. Horizontal: anchors (0, 0.5), second sits to the right.
    static func split(
        texture: SKTexture,
        ratio: CGFloat,
        axis: SplitAxis = .vertical,
        displaySize: CGSize
    ) -> (first: SKSpriteNode, second: SKSpriteNode) {
        let clamped = max(0.01, min(0.99, ratio))

        switch axis {
        case .vertical:
            let firstTex = SKTexture(rect: CGRect(x: 0, y: 0, width: 1, height: clamped), in: texture)
            let secondTex = SKTexture(rect: CGRect(x: 0, y: clamped, width: 1, height: 1 - clamped), in: texture)

            let firstSize = CGSize(width: displaySize.width, height: displaySize.height * clamped)
            let secondSize = CGSize(width: displaySize.width, height: displaySize.height * (1 - clamped))

            let first = SKSpriteNode(texture: firstTex, size: firstSize)
            first.anchorPoint = CGPoint(x: 0.5, y: 0)
            first.position = .zero

            let second = SKSpriteNode(texture: secondTex, size: secondSize)
            second.anchorPoint = CGPoint(x: 0.5, y: 0)
            second.position = CGPoint(x: 0, y: firstSize.height)

            return (first, second)

        case .horizontal:
            let firstTex = SKTexture(rect: CGRect(x: 0, y: 0, width: clamped, height: 1), in: texture)
            let secondTex = SKTexture(rect: CGRect(x: clamped, y: 0, width: 1 - clamped, height: 1), in: texture)

            let firstSize = CGSize(width: displaySize.width * clamped, height: displaySize.height)
            let secondSize = CGSize(width: displaySize.width * (1 - clamped), height: displaySize.height)

            let first = SKSpriteNode(texture: firstTex, size: firstSize)
            first.anchorPoint = CGPoint(x: 0, y: 0.5)
            first.position = .zero

            let second = SKSpriteNode(texture: secondTex, size: secondSize)
            second.anchorPoint = CGPoint(x: 0, y: 0.5)
            second.position = CGPoint(x: firstSize.width, y: 0)

            return (first, second)
        }
    }
}
