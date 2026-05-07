//
//  PoliceGameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit


class PoliceGameScene: SKScene {
    var bg = SKSpriteNode(imageNamed: "map_bg")
    
    override func didMove(to view: SKView) {
        bg.size = size
        bg.position = CGPoint(x: size.width / 2, y: size.width / 2)
        addChild(bg)
    }
    
    // TODO: implement police game scene
    // - add player
    // - add npc
    // - add collision unable to exit before talk to npc
}
