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
    var joystickEntity: JoystickEntity?
    var cam: SKCameraNode?
    var minimapStateViewModel: MinimapStateViewModel?
    
    override func didMove(to view: SKView) {
        // when the scene is first loaded
        self.playerEntity = PlayerEntity(playerInfo: PlayerInfo())
        self.joystickEntity = JoystickEntity(sceneSize: size)
        
        self.setupBackground()
        self.setupCamera()
        self.setupPlayer()
        self.setupJoystick()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // if any touch event occurs
        touchJoystick(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            moveJoystickKnob(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        releaseJoystick()
    }
    
    override func update(_ currentTime: TimeInterval) {
        movePlayer()
        setMapPosition()
    }
}
