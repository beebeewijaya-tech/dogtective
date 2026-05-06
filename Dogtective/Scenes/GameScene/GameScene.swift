//
//  GameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var playerEntity: PlayerEntity?
    
    override func didMove(to view: SKView) {
        // when the scene is first loaded
        self.playerEntity = PlayerEntity(playerInfo: PlayerInfo())
        
        self.setupPlayer()
    }
}
