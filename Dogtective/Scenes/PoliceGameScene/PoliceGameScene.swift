//
//  PoliceGameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 06/05/26.
//

import SpriteKit
import Sentry

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
    var questStateViewModel: QuestStateViewModel?
    var gameSettingsViewModel: GameSettingsViewModel?
    var backpackStateViewModel: BackpackStateViewModel?
    var cutsceneViewModel: CutsceneViewModel?
    var pageStateViewModel: PageStateViewModel?
    var levelViewModel: LevelViewModel?

    // MARK: - NPC system
    var npcSystem: NpcSystem?

    // MARK: - Local Property
    private var questDone = 0
    private lazy var quest = questStateViewModel?.currentQuest
    private var isTransitioning = false
    private var nextScene: SKScene?
    
    
    // MARK: - Entities for NPC
    // TODO: fix the dialog to use from story
    var npcs: [NpcEntity] = [
        NpcEntity(id: 1, name: "Max Holloway", type: .police, position: CGPoint(x: 322.0, y: 184.3333282470703), dialog: DialogUtils.dummyPoliceDialogs()),
        NpcEntity(id: 2, name: "Gideon Vance", type: .police, position: CGPoint(x: 375.3333435058594, y: 228.0), dialog: DialogUtils.dummyPoliceDialogs()),
        NpcEntity(id: 6, name: "Oliver Sniff", type: .npc, position: CGPoint(x: 424.3333435058594, y: 119.3333511352539), dialog: DialogUtils.dummyDialogs() + [Dialog(message: "Bones disappear at night", evidence: true)]),
        NpcEntity(id: 7, name: "Chester Bones", type: .npc, position: CGPoint(x: 457.6666564941406, y: 61.33332824707031), dialog: DialogUtils.dummyDialogs() + [Dialog(message: "No visible tracks near the missing spots", evidence: true)]),
        NpcEntity(id: 10, name: "Felix Waggins", type: .npc, position: CGPoint(x: 611.6666870117188, y: 75.66665649414062), dialog: DialogUtils.dummyDialogs() + [Dialog(message: "I've seen Chichi in the area multiple of times....", evidence: true)]),
    ]
    
    // MARK: - Property
    private var lastUpdateTime: TimeInterval = 0
    var sceneTransaction: Span?
    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = .zero
        
        self.sceneTransaction = SentrySDK.startTransaction(
            name: "PoliceGameScene",
            operation: "police.game.scene",
            bindToScope: true
        )
        
        let initSpan = sceneTransaction?.startChild(
            operation: "scene.init",
            description: "Setting up Entities and Systems"
        )
        
        // register entity or property
        self.playerEntity = PlayerEntity()
        self.joystickEntity = JoystickEntity(sceneSize: size)
        
        // register system
        self.movementSystem = MovementSystem(joystickEntity: joystickEntity, playerEntity: playerEntity)
        self.ysortSystem = YSortSystem()
        self.joystickSystem = JoystickSystem(joystickEntity: joystickEntity, scene: self)
        
        self.setupBackground()
        self.setupPlayer()

        self.npcSystem = NpcSystem(
            scene: self,
            npcs: npcs,
            playerEntity: playerEntity,
            dialogStateViewModel: dialogStateViewModel
        )

        self.npcSystem?.gameSettingsViewModel = self.gameSettingsViewModel
        
        self.npcSystem?.onEvidenceDialogShown = { [weak self] _ in
            self?.checkQuest()
        }
        self.npcSystem?.setup { [weak self] npc in
            self?.register(npc)
        }

        self.setupCollisions()
        self.setupColliderEntities()
        self.setupJoystick()
        
        physicsWorld.contactDelegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSaveRequested),
            name: .saveGameRequested,
            object: nil
        )

        initSpan?.finish()
        
        
        prepareGameScene()
    }

    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self, name: .saveGameRequested, object: nil)
        resetMemory()
    }
    
    func resetMemory() {
        removeAllActions()
        removeAllChildren()
        movementSystem = nil
        ysortSystem = nil
        joystickSystem = nil
        npcSystem = nil
        playerEntity = nil
        joystickEntity = nil
        minimapStateViewModel = nil
        dialogStateViewModel = nil
        questStateViewModel = nil
        gameSettingsViewModel = nil
        backpackStateViewModel = nil
        cutsceneViewModel = nil
        pageStateViewModel = nil
        nextScene = nil
        sceneTransaction = nil
    }

    @objc private func handleSaveRequested() {
        guard let vm = gameSettingsViewModel else { return }
        if let pos = playerEntity?.node?.position {
            vm.playerPosition = pos
        }
        if let backpack = backpackStateViewModel {
            vm.numOfEvidence = backpack.collectedKeys.count
            vm.collectedEvidence = Array(backpack.collectedKeys)
        }
        if let quest = questStateViewModel {
            vm.currentQuest = quest.currentIndex
        }
        vm.save()
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
        checkSceneTransition()
        // NPC bubble + dialog handling
        npcSystem?.update()
    }


    // MARK: - Collisions check
    func didBegin(_ contact: SKPhysicsContact) {
        npcSystem?.handleContactBegin(contact)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        npcSystem?.handleContactEnd(contact)
    }
    
    
    // MARK: - Navigation to main scene
    func prepareGameScene() {
        let scene = GameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        scene.dialogStateViewModel = dialogStateViewModel
        scene.questStateViewModel = questStateViewModel
        scene.gameSettingsViewModel = gameSettingsViewModel
        scene.backpackStateViewModel = backpackStateViewModel
        scene.cutsceneViewModel = cutsceneViewModel
        scene.pageStateViewModel = pageStateViewModel
        scene.levelViewModel = levelViewModel
        scene.setupBackground() // setup background
        nextScene = scene
     }
    
    
    private func checkSceneTransition() {
        guard !isTransitioning else { return }
        guard questStateViewModel?.currentIndex == 1 else { return }
        guard let nextScene = nextScene else { return }
        guard let playerEntity = playerEntity else { return }
        guard let node = playerEntity.node else { return }

        let door = CGPoint(x: 437.3, y: 289.6)
        let dx = node.position.x - door.x
        let dy = node.position.y - door.y
        let distance = hypot(dx, dy)
        
        if distance < 30 {
            Task {
                let transitionSpan = sceneTransaction?.startChild(operation: "scene.transition", description: "Loading Game Scene")
                isTransitioning = true
                
                // finishing sentry
                transitionSpan?.finish()
                sceneTransaction?.finish()
                cutsceneViewModel?.setCutscene(cutscene: 2)
                gameSettingsViewModel?.currentCutscene = 2
                gameSettingsViewModel?.save()
                
                view?.presentScene(nextScene, transition: .fade(withDuration: 0.5))
            }
        }
    }
    
    // MARK: - Chat System

    private func checkQuest() {
        Task {
            try await questStateViewModel?.recordProgress()
            gameSettingsViewModel?.currentQuest = questStateViewModel?.currentIndex ?? 0
            gameSettingsViewModel?.save()
        }
    }
}
