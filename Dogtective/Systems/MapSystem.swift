//
//  LayoutSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit


// MARK: - Map System
// will contains the setup about the map, map position
extension GameScene {
    func setupBackground() {
        let gridSize: CGFloat = 4000
        let cellSize: CGFloat = 100
        let path = CGMutablePath()
        let half = gridSize / 2
        let steps = Int(gridSize / cellSize)

        for i in 0...steps {
            let x = -half + CGFloat(i) * cellSize
            path.move(to: CGPoint(x: x, y: -half))
            path.addLine(to: CGPoint(x: x, y: half))
        }
        for i in 0...steps {
            let y = -half + CGFloat(i) * cellSize
            path.move(to: CGPoint(x: -half, y: y))
            path.addLine(to: CGPoint(x: half, y: y))
        }

        let grid = SKShapeNode(path: path)
        grid.strokeColor = UIColor.green.withAlphaComponent(0.2)
        grid.lineWidth = 1
        grid.zPosition = -0.5
        addChild(grid)
    }
}
