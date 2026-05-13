//
//  ObstacleEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import SpriteKit
import GameplayKit


// MARK: Obstacle config
struct ObstacleConfig {
    let textureName: String
    let position: CGPoint
    let scale: CGFloat
    let axis: SplitAxis
    let ratio: CGFloat
    let collisionWidthRatio: CGFloat
    let collisionHeightRatio: CGFloat
    let ysortEnabled: Bool
    let secondPieceZ: CGFloat
    let zOffset: CGFloat  // bias for overlapping entities; positive = draws in front
}

extension ObstacleConfig {
    static func bigTree(at pos: CGPoint, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: "big_tree",
            position: pos,
            scale: 0.25,
            axis: .vertical,
            ratio: 0.4,
            collisionWidthRatio: 0.25,
            collisionHeightRatio: 0.35,
            ysortEnabled: true,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }

    static func building(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.5,
            axis: .horizontal,
            ratio: 0.6,
            collisionWidthRatio: 1.0,
            collisionHeightRatio: 0.8,
            ysortEnabled: false,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }
}

// MARK: ObstacleEntity
class ObstacleEntity: BaseEntity {
    /// Preferred initializer. Texture is owned by the caller (e.g. ChunkManager's ref cache)
    /// so unloading a chunk can actually free the GPU memory.
    init(config: ObstacleConfig, texture: SKTexture) {
        let container = SKNode()
        container.position = config.position
        super.init(node: container)

        let display = CGSize(
            width: texture.size().width * config.scale,
            height: texture.size().height * config.scale
        )

        let parts = SpriteSplitter.split(
            texture: texture,
            ratio: config.ratio,
            axis: config.axis,
            displaySize: display
        )
        container.addChild(parts.first)
        container.addChild(parts.second)
        parts.first.zPosition = 0
        parts.second.zPosition = config.secondPieceZ

        addComponent(SplitSpriteComponent(first: parts.first, second: parts.second))

        // First piece display size (depends on axis).
        let firstWidth: CGFloat
        let firstHeight: CGFloat
        switch config.axis {
        case .vertical:
            firstWidth = display.width
            firstHeight = display.height * config.ratio
        case .horizontal:
            firstWidth = display.width * config.ratio
            firstHeight = display.height
        }

        let collisionW = firstWidth * config.collisionWidthRatio
        let collisionH = firstHeight * config.collisionHeightRatio

        let offset: CGPoint
        switch config.axis {
        case .vertical:
            offset = CGPoint(x: 0, y: collisionH / 2)
        case .horizontal:
            offset = CGPoint(x: firstWidth / 2, y: 0)
        }

        let body = PhysicsBodyComponent(
            shape: .rectangle(CGSize(width: collisionW, height: collisionH)),
            offset: offset,
            isDynamic: false,
            category: PhysicsCategory.obstacle,
            collidesWith: PhysicsCategory.player
        )
        addComponent(body)
        body.attach(to: parts.first)

        if config.ysortEnabled {
            addComponent(YSortComponent(zOffset: config.zOffset))
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
}
