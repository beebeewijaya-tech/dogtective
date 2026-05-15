//
//  ObstacleEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import GameplayKit
import SpriteKit

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
    var firstPieceZ: CGFloat = 0
    let secondPieceZ: CGFloat
    let zOffset: CGFloat // bias for overlapping entities; positive = draws in front
    // Stable id assigned by MapSystem so ChunkManager can dedupe when the same
    // obstacle is bucketed into multiple chunks (tall sprites span boundaries).
    var id: Int = 0
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

    static func coneTree(at pos: CGPoint, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: "cone_tree",
            position: pos,
            scale: 0.35,
            axis: .vertical,
            ratio: 0.45,
            collisionWidthRatio: 0.25,
            collisionHeightRatio: 0.25,
            ysortEnabled: true,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }

    static func building(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.33,
            axis: .vertical,
            ratio: 0.7,
            collisionWidthRatio: 0.87,
            collisionHeightRatio: 0.7,
            ysortEnabled: true,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }

    static func buildingFullCollision(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.33,
            axis: .vertical,
            ratio: 1.0,
            collisionWidthRatio: 1.0,
            collisionHeightRatio: 1.0,
            ysortEnabled: true,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }
    
    static func smallObstacle(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.3,
            axis: .vertical,
            ratio: 0.25,
            collisionWidthRatio: 1.0,
            collisionHeightRatio: 1.0,
            ysortEnabled: true,
            secondPieceZ: 0,
            zOffset: zOffset
        )
    }
    
    static func car(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.3,
            axis: .vertical,
            ratio: 0.55,
            collisionWidthRatio: 1.0,
            collisionHeightRatio: 1.0,
            ysortEnabled: true,
            secondPieceZ: 0,
            zOffset: zOffset
        )
    }
    
    static func smallStickyObstacle(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.3,
            axis: .vertical,
            ratio: 1.0,
            collisionWidthRatio: 1.0,
            collisionHeightRatio: 1.0,
            ysortEnabled: true,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }
    
    static func treeOnPot(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.35,
            axis: .vertical,
            ratio: 0.65,
            collisionWidthRatio: 0.83,
            collisionHeightRatio: 0.6,
            ysortEnabled: true,
            secondPieceZ: 1000,
            zOffset: zOffset
        )
    }
    
    static func pole(at pos: CGPoint, textureName: String, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: textureName,
            position: pos,
            scale: 0.33,
            axis: .vertical,
            ratio: 0.3,
            collisionWidthRatio: 0.53,
            collisionHeightRatio: 0.6,
            ysortEnabled: true,
            secondPieceZ: 0,
            zOffset: zOffset
        )
    }
    
    static func fence(at pos: CGPoint, zOffset: CGFloat = 0) -> ObstacleConfig {
        ObstacleConfig(
            textureName: "fence_long",
            position: pos,
            scale: 0.33,
            axis: .vertical,
            ratio: 0.35,
            collisionWidthRatio: 1.0,
            collisionHeightRatio: 1.0,
            ysortEnabled: true,
            secondPieceZ: 0,
            zOffset: zOffset
        )
    }

    enum FenceDirection {
        case left, right, up, down
    }
    static func fenceLine(from pos: CGPoint,
                          direction: FenceDirection,
                          count: Int,
                          spacing: CGFloat = 75.1,
                          zOffset: CGFloat = 0) -> [ObstacleConfig] {
        guard count > 0 else { return [] }
        let step: CGPoint
        switch direction {
        case .left:  step = CGPoint(x: -spacing, y: 0)
        case .right: step = CGPoint(x:  spacing, y: 0)
        case .up:    step = CGPoint(x: 0, y:  spacing)
        case .down:  step = CGPoint(x: 0, y: -spacing)
        }
        return (0..<count).map { i in
            let p = CGPoint(x: pos.x + step.x * CGFloat(i),
                            y: pos.y + step.y * CGFloat(i))
            return .fence(at: p, zOffset: zOffset)
        }
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
        parts.first.zPosition = config.firstPieceZ + config.zOffset
        parts.second.zPosition = config.secondPieceZ + config.zOffset

        addComponent(SplitSpriteComponent(first: parts.first,
                                          second: parts.second))

        // First piece display size (depends on axis).
        let firstWidth: CGFloat
        let firstHeight: CGFloat
        switch config.axis {
        case .vertical:
            firstWidth = display.width
            firstHeight = display.height * config.ratio
        case .horizontal, .horizontalReversed:
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
        case .horizontalReversed:
            // first piece anchored on its right edge, so it extends to the LEFT
            // of container.position — mirror the horizontal offset.
            offset = CGPoint(x: -firstWidth / 2, y: 0)
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

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
