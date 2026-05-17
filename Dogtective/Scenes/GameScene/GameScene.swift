//
//  GameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit
import GameplayKit
import Sentry

class GameScene: SKScene, SKPhysicsContactDelegate {
    var playerEntity: PlayerEntity?
    var joystickEntity: JoystickEntity?
    var cam: SKCameraNode?
    var movementSystem: MovementSystem?
    var ysortSystem: YSortSystem?
    var joystickSystem: JoystickSystem?
    var chunkManager: ChunkManager?

    
    // MARK: - ViewModel
    var questDialogViewModel: QuestStateViewModel?
    var minimapStateViewModel: MinimapStateViewModel?
    var dialogStateViewModel: DialogStateViewModel?
    var backpackStateViewModel: BackpackStateViewModel?

    // MARK: - Evidence
    var evidenceSystem: EvidenceSystem?

    // MARK: - NPCs
    // TODO: Change the dialog later and behaviour later (with gK State maybe)
    var npcSystem: NpcSystem?
    private var npcs: [NpcEntity] = [
        NpcEntity(
            name: "Bruno 20 assist", type: .npcKid,
            position: CGPoint(x: -634, y: -83),
            dialog: DialogUtils.dummyDialogs() + [
                Dialog(
                    message: "I saw a tall shadow lurking last night near the alley...",
                    evidence: true,
                    evidenceReward: "siluet",
                    evidenceFloating: .siluet
                )
            ]
        ),
        NpcEntity(
            id: 8, name: "Old Karen", type: .npc,
            position: CGPoint(x: -694, y: -83),
            dialog: DialogUtils.dummyDialogs() + [
                Dialog(
                    message: "Strange things happen around here lately...",
                    evidence: true,
                    evidenceReward: "fur",
                    evidenceFloating: .fur
                )
            ]
        ),
    ]

    
    // TODO: think better way to put global variable
    var bonfirePosition = CGPoint(x: 1792, y: 492)
    var foodStallPosition: [CGPoint] = [
        // from left map to right
        CGPoint(x: -124, y: 131),
        CGPoint(x: -32, y: 514),
        CGPoint(x: 1787, y: 88),
    ]
//    var lampLightPosition: [CGPoint] = [
//        // from left map to right
//        CGPoint(x: -690, y: -126),
//        CGPoint(x: -198, y: -53),
//        CGPoint(x: 444, y: -23),
//        CGPoint(x: 499, y: 522),
//        CGPoint(x: 1796, y: 231),
//    ]
    
    // MARK: - Property
    var entities: [BaseEntity] = []
    private var lastUpdateTime: TimeInterval = 0
    var sceneTransaction: Span?

    override func didMove(to view: SKView) {
        // setup sentry
        self.sceneTransaction = SentrySDK.startTransaction(
            name: "MainGameScene",
            operation: "main.game.scene",
            bindToScope: true
        )
        
        let initSpan = sceneTransaction?.startChild(
            operation: "scene.init",
            description: "Setting up Entities and Systems"
        )
        
        // 2. Register UIKit observers for app lifecycle events
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAppBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        // when the scene is first loaded
        self.physicsWorld.gravity = .zero
        self.playerEntity = PlayerEntity()
        self.joystickEntity = JoystickEntity(sceneSize: size)
        self.setupCamera()
        self.movementSystem = MovementSystem(joystickEntity: self.joystickEntity, playerEntity: self.playerEntity)
        self.ysortSystem = YSortSystem()
        self.joystickSystem = JoystickSystem(joystickEntity: joystickEntity, cam: cam, scene: self)

        self.setupPlayer()
        self.setupJoystick()
        
        if chunkManager == nil {
            // we pre-warmed the setupbackground call from police transition scene
            self.setupBackground()
        }
        
        initSpan?.finish()

        self.setupEvidences()

        self.npcSystem = NpcSystem(
            scene: self,
            npcs: npcs,
            playerEntity: playerEntity,
            dialogStateViewModel: dialogStateViewModel
        )
        self.npcSystem?.setup { [weak self] npc in
            self?.register(npc)
        }
        self.physicsWorld.contactDelegate = self

        Task {
            // create new quest
            let newQuest = Quest(
                title: "Find the first evidence on the park",
                done: false,
                doneCondition: 1,
                isLoading: false
            )
            
            // 
            try await questDialogViewModel?.doneQuest(newQuest)
        }
        
        let breadcrumb = Breadcrumb(level: .info, category: "gameplay.lifecycle")
        breadcrumb.message = "User entered MainGameScene exploration mode."
        SentrySDK.addBreadcrumb(breadcrumb)
    }

    // Add an entity to the world: track it, register its components with each system.
    func register(_ entity: BaseEntity) {
        entities.append(entity)
        ysortSystem?.register(entity)
    }
    
    
    // observer for sentry
    @objc private func handleAppBackground() {
        if let transaction = sceneTransaction {
            transaction.setData(value: "User backgrounded via UIKit observer", key: "exit.reason")
            transaction.finish()
        }
        
        // Force Sentry to flush the transaction trace to the server immediately
        SentrySDK.flush(timeout: 2.0)
    }
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return } // if any touch event occurs
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
        guard let joystickSystem = joystickSystem else { return }
        joystickSystem.releaseJoystick()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        movementSystem?.update(deltaTime: dt)
        cameraFollowPlayer()
        setMapPosition()
        ysortSystem?.update(deltaTime: dt)
        if let cam = self.cam {
            chunkManager?.update(cameraPosition: cam.position)
        }
        evidenceSystem?.update(deltaTime: dt)
        npcSystem?.update()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        npcSystem?.handleContactBegin(contact)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        npcSystem?.handleContactEnd(contact)
    }
}
