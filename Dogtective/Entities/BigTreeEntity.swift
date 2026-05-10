//
//  BigTreeEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 10/05/26.
//

import SpriteKit

class BigTreeEntity: SKNode {
    let bottomSprite: SKSpriteNode
    let topSprite: SKSpriteNode

    /// - Parameters:
    ///   - position: world position. Anchor is bottom-center
    ///   - scale: 1.0 = native texture size. 0.28 sweet spot for 550x671 image.
    ///   - bottomRatio: 0..1 portion of texture treated as bottom (gets collision + y-sort)
    // TODO: for big tree with 550x671, sweet spot is 0.28, tweak later
    init(position: CGPoint, scale: CGFloat = 0.28, bottomRatio: CGFloat = 0.4) {
        let texture = SKTexture(imageNamed: "big_tree")
        let baseSize = texture.size()
        let displaySize = CGSize(width: baseSize.width * scale, height: baseSize.height * scale)

        let parts = SpriteSplitter.split(texture: texture, bottomRatio: bottomRatio, displaySize: displaySize)
        self.bottomSprite = parts.bottom
        self.topSprite = parts.top

        super.init()
        self.position = position
        addChild(bottomSprite)
        addChild(topSprite)

        bottomSprite.zPosition = 0
        topSprite.zPosition = 1000

        let trunkWidth = displaySize.width * 0.25
        let trunkHeight = displaySize.height * bottomRatio * 0.35
        let trunkSize = CGSize(width: trunkWidth, height: trunkHeight)
        let trunkOffset = CGPoint(x: 0, y: trunkHeight / 2)
        CollisionSystem.applyStaticBody(to: bottomSprite, shape: .rectangle(trunkSize), offset: trunkOffset)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
