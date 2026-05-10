//
//  BigTreeEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 10/05/26.
//

import SpriteKit

class BigTreeEntity: SKSpriteNode {
    // init the big tree, change the scale for the sweet spot (now is 0.28 with 550px x 671px image)
    init(position: CGPoint, scale: CGFloat = 0.28) {
        let texture = SKTexture(imageNamed: "big_tree")
        let baseSize = texture.size()
        super.init(texture: texture, color: .clear, size: CGSize(
            width: baseSize.width * scale,
            height: baseSize.height * scale
        ))
        self.anchorPoint = CGPoint(x: 0.5, y: 0)
        self.position = position
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
