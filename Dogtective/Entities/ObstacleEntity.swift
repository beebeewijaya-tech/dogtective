//
//  ObstacleEntity.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 11/05/26.
//

import Foundation
import GameplayKit

struct ObstacleConfig {
    let textureName: String
    let position: CGPoint
    let scale: CGFloat
    let ratio: CGFloat
    let trunkWidthRatio: CGFloat
    let trunkHeightRatio: CGFloat
}

extension ObstacleConfig {
    static func bigTree(at pos: CGPoint) -> ObstacleConfig {
        ObstacleConfig(
            textureName: "big_tree",
            position: pos,
            scale: 0.28,
            ratio: 0.4,
            trunkWidthRatio: 0.25,
            trunkHeightRatio: 0.35
        )
    }
}

class ObstacleEntity: BaseEntity {
     init(config: ObstacleConfig) {
         let container = SKNode()
         container.position = config.position
         super.init(node: container)
         
         let texture = SKTexture(imageNamed: config.textureName)
         let display = CGSize(
             width: texture.size().width * config.scale,
             height: texture.size().height * config.scale
         )
         
         let parts = SpriteSplitter.split(
             texture: texture,
             ratio: config.ratio,
             axis: .vertical,
             displaySize: display
         )
         container.addChild(parts.first)
         container.addChild(parts.second)
         parts.first.zPosition = 0
         parts.second.zPosition = 1000

         addComponent(SplitSpriteComponent(first: parts.first, second: parts.second))

         let trunkW = display.width * config.trunkWidthRatio
         let trunkH = display.height * config.ratio * config.trunkHeightRatio
         let bodyComponent = PhysicsBodyComponent(
             shape: .rectangle(CGSize(width: trunkW, height: trunkH)),
             offset: CGPoint(x: 0, y: trunkH / 2),
             isDynamic: false,
             category: PhysicsCategory.obstacle,
             collidesWith: PhysicsCategory.player
         )
         addComponent(bodyComponent)
         bodyComponent.attach(to: parts.first)
         
         addComponent(YSortComponent())
     }
     
     required init?(coder aDecoder: NSCoder) { fatalError() }
 }
