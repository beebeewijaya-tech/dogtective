//
//  ChunkRegistry.swift
//  Dogtective
//
//  Created by Fikrah Damar Huda on 13/05/26.
//

import CoreGraphics
import Foundation

/// Static spatial layout of the chunk grid. Pure math — no SpriteKit.
///
/// - `mapOriginBottomLeft` is the scene-space point where the map's bottom-left
///   corner sits.
/// - The grid is addressed top-down: row 0 = top of the image, matching the
///   order the slicer wrote files (`chunk_0` = top-left, `chunk_31` = bottom-right).
struct ChunkRegistry {
    let mapOriginBottomLeft: CGPoint
    let mapSize: CGSize
    let gridCols: Int
    let gridRows: Int

    var chunkSize: CGSize {
        CGSize(width: mapSize.width / CGFloat(gridCols),
               height: mapSize.height / CGFloat(gridRows))
    }

    func chunkCoord(for scenePoint: CGPoint) -> ChunkCoord {
        let local = CGPoint(x: scenePoint.x - mapOriginBottomLeft.x,
                            y: scenePoint.y - mapOriginBottomLeft.y)
        let cs = chunkSize
        let rawCol = Int(floor(local.x / cs.width))
        let rawRowFromBottom = Int(floor(local.y / cs.height))
        let col = clamp(rawCol, min: 0, max: gridCols - 1)
        let rowFromBottom = clamp(rawRowFromBottom, min: 0, max: gridRows - 1)
        let row = (gridRows - 1) - rowFromBottom
        return ChunkCoord(col: col, row: row)
    }

    func chunkCenter(for coord: ChunkCoord) -> CGPoint {
        let cs = chunkSize
        let xFromLeft = (CGFloat(coord.col) + 0.5) * cs.width
        let rowFromBottom = (gridRows - 1) - coord.row
        let yFromBottom = (CGFloat(rowFromBottom) + 0.5) * cs.height
        return CGPoint(x: mapOriginBottomLeft.x + xFromLeft,
                       y: mapOriginBottomLeft.y + yFromBottom)
    }

    func chunks(around centre: ChunkCoord, radius: Int) -> Set<ChunkCoord> {
        var out: Set<ChunkCoord> = []
        for dc in -radius...radius {
            for dr in -radius...radius {
                let c = centre.col + dc
                let r = centre.row + dr
                if c >= 0, c < gridCols, r >= 0, r < gridRows {
                    out.insert(ChunkCoord(col: c, row: r))
                }
            }
        }
        return out
    }

    /// Bundle resource name for a chunk PNG. Chunks live at app bundle root
    /// (Xcode 16 synced groups flatten subfolders) — call sites should use
    /// `Bundle.main.path(forResource: name, ofType: nil)`.
    func backgroundFileName(for coord: ChunkCoord) -> String {
        let index = coord.row * gridCols + coord.col
        return "chunk_\(index).png"
    }

    private func clamp(_ x: Int, min lo: Int, max hi: Int) -> Int {
        Swift.max(lo, Swift.min(hi, x))
    }
}
