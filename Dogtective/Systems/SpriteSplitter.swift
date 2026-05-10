//
//  SpriteSplitter.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 10/05/26.
//

import SpriteKit

struct SpriteSplitter {
    // Split a texture into bottom + top sprites by vertical ratio.
    // `bottomRatio` 0..1 = portion belonging to the bottom sprite.
    // Both sprites use anchorPoint (0.5, 0). Top is positioned above bottom.
    static func split(
        texture: SKTexture,
        bottomRatio: CGFloat,
        displaySize: CGSize
    ) -> (bottom: SKSpriteNode, top: SKSpriteNode) {
        let clamped = max(0.01, min(0.99, bottomRatio))

        let bottomTex = SKTexture(rect: CGRect(x: 0, y: 0, width: 1, height: clamped), in: texture)
        let topTex = SKTexture(rect: CGRect(x: 0, y: clamped, width: 1, height: 1 - clamped), in: texture)

        let bottomSize = CGSize(width: displaySize.width, height: displaySize.height * clamped)
        let topSize = CGSize(width: displaySize.width, height: displaySize.height * (1 - clamped))

        let bottom = SKSpriteNode(texture: bottomTex, size: bottomSize)
        bottom.anchorPoint = CGPoint(x: 0.5, y: 0)
        bottom.position = .zero

        let top = SKSpriteNode(texture: topTex, size: topSize)
        top.anchorPoint = CGPoint(x: 0.5, y: 0)
        top.position = CGPoint(x: 0, y: bottomSize.height)

        return (bottom, top)
    }
}
