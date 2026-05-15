//
//  PoliceGameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit

class PoliceGameScene: SKScene, SKPhysicsContactDelegate {
    // MARK: - Player related
    var playerEntity: PlayerEntity?
    var joystickEntity: JoystickEntity?
    var bg = SKSpriteNode(imageNamed: "map_police")
    var movementSystem: MovementSystem?
    var ysortSystem: YSortSystem?
    var joystickSystem: JoystickSystem?

    // MARK: - ViewModel
    var minimapStateViewModel: MinimapStateViewModel?
    var dialogStateViewModel: DialogStateViewModel?
    
    
    // MARK: - Local Property
    private var activeNpc: NpcEntity?
    private var currentDialogState: DialogState?
    
    
    // MARK: - Entities for NPC
    // TODO: fix the dialog to use from story
    var npcs: [NpcEntity] = [
        NpcEntity(id: 1, name: "Max Holloway", type: .police, position: CGPoint(x: 322.0, y: 184.3333282470703), dialog: DialogUtils.dummyPoliceDialogs()),
        NpcEntity(id: 2, name: "Gideon Vance", type: .police, position: CGPoint(x: 375.3333435058594, y: 228.0), dialog: DialogUtils.dummyPoliceDialogs()),
        NpcEntity(id: 6, name: "Jon Jones", type: .npc, position: CGPoint(x: 424.3333435058594, y: 119.3333511352539), dialog: DialogUtils.dummyDialogs()),
        NpcEntity(id: 7, name: "Mario Balotelli", type: .npc, position: CGPoint(x: 457.6666564941406, y: 61.33332824707031), dialog: DialogUtils.dummyDialogs()),
        NpcEntity(id: 10, name: "King Zharif", type: .npc, position: CGPoint(x: 611.6666870117188, y: 75.66665649414062), dialog: DialogUtils.dummyDialogs()),
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
        
        
        physicsWorld.contactDelegate = self
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
        guard let dialogStateViewModel = dialogStateViewModel else { return }
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        movementSystem?.update(deltaTime: dt)
        ysortSystem?.update(deltaTime: dt)
        
        // TODO: for now will do this to transition on the gamescene
        checkSceneTransition()
        
        
        // check chat
        if dialogStateViewModel.isChat == .chat {
            guard currentDialogState != .chat else { return }
            currentDialogState = .chat
            dialogStateViewModel.dialog = activeNpc?.dialogComponent?.getDialog()
            dialogStateViewModel.npc = activeNpc?.name
        } else {
            currentDialogState = nil
        }
    }
    
    
    // MARK: - Collisions check
    func didBegin(_ contact: SKPhysicsContact) {
        guard let dialogStateViewModel = dialogStateViewModel else { return }
        
        let mask = Set([contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask])
        switch mask {
        case [PhysicsCategory.player, PhysicsCategory.npc]:
            let npc = contact.bodyA.categoryBitMask == PhysicsCategory.npc ? contact.bodyA : contact.bodyB
            activeNpc?.animation?.removeBubbleChat()
            activeNpc = npcs.first { $0.node == npc.node }
            activeNpc?.animation?.playBubbleChat()
            dialogStateViewModel.setState(.bubble)
        default:
            return
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        guard let dialogStateViewModel = dialogStateViewModel else { return }

        let mask = Set([contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask])
        switch mask {
        case [PhysicsCategory.player, PhysicsCategory.npc]:
            activeNpc?.animation?.removeBubbleChat()
            activeNpc = nil
            dialogStateViewModel.setState(.idle)
        default:
            return
        }

    }
    
    
    // MARK: - Navigation to main scene
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
