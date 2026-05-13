//
//  PoliceGameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit

class PoliceGameScene: SKScene {
    // MARK: - Player related
    var playerEntity: PlayerEntity?
    var joystickEntity: JoystickEntity?
    var bg = SKSpriteNode(imageNamed: "map_police")
    var minimapStateViewModel: MinimapStateViewModel?
    var movementSystem: MovementSystem?
    var ysortSystem: YSortSystem?
    var joystickSystem: JoystickSystem?

    
    // MARK: - Entities for NPC
    var npcs: [NpcEntity] = [
        NpcEntity(id: 1, type: .police, position: CGPoint(x: 322.0, y: 184.3333282470703)),
        NpcEntity(id: 2, type: .police, position: CGPoint(x: 375.3333435058594, y: 228.0)),
        NpcEntity(id: 6, type: .npc, position: CGPoint(x: 424.3333435058594, y: 119.3333511352539)),
        NpcEntity(id: 7, type: .npc, position: CGPoint(x: 457.6666564941406, y: 61.33332824707031)),
        NpcEntity(id: 10, type: .npc, position: CGPoint(x: 611.6666870117188, y: 75.66665649414062)),
    ]
    
    // MARK: - Property
    private var lastUpdateTime: TimeInterval = 0
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = .zero
        
        // register entity or property
        self.playerEntity = PlayerEntity()
        self.joystickEntity = JoystickEntity(sceneSize: size)
        
        // register system
        self.movementSystem = MovementSystem(joystickEntity: joystickEntity, playerEntity: playerEntity)
        self.ysortSystem = YSortSystem()
        self.joystickSystem = JoystickSystem(joystickEntity: joystickEntity, scene: self)
        
        self.setupBackground()
        self.setupPlayer()
        self.setupNPCs()
        self.setupCollisions()
        self.setupJoystick()
    }
    
    func setupBackground() {
        let scale = min(size.width / bg.size.width, size.height / bg.size.height)
        bg.setScale(scale)
        bg.position = CGPoint(x: size.width/2, y: size.height/2)
        bg.zPosition = -10000
        addChild(bg)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        guard let joystickSystem = joystickSystem else { return }
        print("Location ", touch.location(in: self))
        joystickSystem.touchJoystick(touch: touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let joystickSystem = joystickSystem else { return }

        for touch in touches {
            joystickSystem.moveJoystickKnob(touch: touch)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystickSystem?.releaseJoystick()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        movementSystem?.update(deltaTime: dt)
        ysortSystem?.update(deltaTime: dt)
        
        // TODO: for now will do this to transition on the gamescene
        checkSceneTransition()
    }
    
    func checkSceneTransition() {
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.node else { return }
        
        let door = CGPoint(x: 437.3, y: 289.6)
        let dx = node.position.x - door.x
        let dy = node.position.y - door.y
        let distance = hypot(dx, dy)
        
        if distance < 30 {
            let nextScene = GameScene(size: size)
            nextScene.minimapStateViewModel = minimapStateViewModel
            view?.presentScene(nextScene, transition: .fade(withDuration: 0.5))
        }
    }
}
