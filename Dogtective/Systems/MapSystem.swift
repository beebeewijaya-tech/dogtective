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
        let backgroundTexture = SKTexture(imageNamed: "map_district")
        let background = SKSpriteNode(texture: backgroundTexture)
        background.size = CGSize(width: 3634, height: 1449)
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(background)
        
        
        // TODO: fix and think to render this somewhere else
        setupFire()
        setupFoodStallSmoke()
        setupLampLight()
        setupBigTrees()
    }

    func setupBigTrees() {
        for pos in self.bigTreePositions {
            let tree = BigTreeEntity(position: pos)
            addChild(tree)
        }
    }
    
    func setupFire() {
        if let fire = SKEmitterNode(fileNamed: "BonFire") {
            fire.position = bonfirePosition
            fire.particleSize = CGSize(width: 100, height: 100)
            addChild(fire)
        }
    }
    
    
    func setupFoodStallSmoke() {
        for pos in self.foodStallPosition {
            if let smoke = SKEmitterNode(fileNamed: "FoodStallSmoke") {
                smoke.position = pos
                addChild(smoke)
            }
        }
    }
    
    func setupLampLight() {
        for pos in self.lampLightPosition {
            if let lamp = SKEmitterNode(fileNamed: "Lamp") {
                lamp.position = pos
                addChild(lamp)
            }
        }
    }
}
