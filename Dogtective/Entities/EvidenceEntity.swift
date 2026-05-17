//
//  EvidenceEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 16/05/26.
//

import SpriteKit
import GameplayKit

final class EvidenceEntity: BaseEntity {

    init(config: EvidenceConfig) {
        let container = SKNode()
        container.position = config.position
        super.init(node: container)

        let evidence = EvidenceComponent(config: config)
        evidence.attach(to: container)
        addComponent(evidence)

        let size = evidence.mainSprite.size
        let collisionSize = config.collisionSize
            ?? CGSize(width: size.width * 0.7, height: size.height * 0.4)
        let collisionOffset = config.collisionOffset == .zero
            ? CGPoint(x: 0, y: -size.height * 0.3)
            : config.collisionOffset

        let body = PhysicsBodyComponent(
            shape: .rectangle(collisionSize),
            offset: collisionOffset,
            isDynamic: false,
            category: PhysicsCategory.obstacle,
            collidesWith: PhysicsCategory.player
        )
        addComponent(body)
        body.attach(to: container)

        addComponent(YSortComponent())
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { fatalError() }

    var evidence: EvidenceComponent? {
        component(ofType: EvidenceComponent.self)
    }
}
