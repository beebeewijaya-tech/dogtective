//
//  ChunkTypes.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 13/05/26.
//

import CoreGraphics
import SpriteKit

struct ChunkCoord: Hashable {
    let col: Int
    let row: Int
}

struct ParticleConfig {
    let fileName: String
    let position: CGPoint
    let particleSize: CGSize?
    var zPosition: CGFloat = 0
    var burnOnly: Bool = false
}

struct ChunkContent {
    let coord: ChunkCoord
    let backgroundImageFileName: String
    let obstacleConfigs: [ObstacleConfig]
    let particleConfigs: [ParticleConfig]
    var loadedNodes: [SKNode] = []
}
