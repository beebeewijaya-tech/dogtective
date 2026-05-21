//
//  GameScene.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SpriteKit
import GameplayKit
import Sentry
import Combine

class GameScene: SKScene, SKPhysicsContactDelegate {
    var playerEntity: PlayerEntity?
    var joystickEntity: JoystickEntity?
    var cam: SKCameraNode?
    var movementSystem: MovementSystem?
    var ysortSystem: YSortSystem?
    var joystickSystem: JoystickSystem?
    var chunkManager: ChunkManager?
    
    
    // MARK: - ViewModel
    var questStateViewModel: QuestStateViewModel?
    var minimapStateViewModel: MinimapStateViewModel?
    var dialogStateViewModel: DialogStateViewModel?
    var backpackStateViewModel: BackpackStateViewModel?
    var cutsceneViewModel: CutsceneViewModel?
    var pageStateViewModel: PageStateViewModel?
    var gameSettingsViewModel: GameSettingsViewModel?
    
    // MARK: - Evidence
    var evidenceSystem: EvidenceSystem?
    
    // MARK: - NPCs
    // TODO: Change the dialog later and behaviour later (with gK State maybe)
    var npcSystem: NpcSystem?
    private var npcs: [NpcEntity] = [
        NpcEntity(
            id: 1, name: "Baxter Whitmore", type: .npc,
            position: CGPoint(x: -1172, y: -373),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 2, name: "Winston Barkley", type: .npc,
            position: CGPoint(x: -808, y: 598),
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
            id: 3, name: "Kevin Durant", type: .npc,
            position: CGPoint(x: 193, y: 775),
            // relocates to (216, 834) once evidence count >= openFenceThreshold
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 4, name: "Rupert Howl", type: .npc,
            position: CGPoint(x: -447, y: -325),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 5, name: "Milo Hound", type: .npc,
            position: CGPoint(x: 1510, y: -309),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 6, name: "Oliver Sniff", type: .npc,
            position: CGPoint(x: 1922, y: -26),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 7, name: "Chester Bones", type: .npc,
            position: CGPoint(x: 933, y: -70),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 8, name: "Archie Tailor", type: .npc,
            position: CGPoint(x: 523, y: 419),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 9, name: "Jasper Collier", type: .npc,
            position: CGPoint(x: -83, y: 23),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            id: 10, name: "Felix Waggins", type: .npc,
            position: CGPoint(x: -1209, y: 47),
            dialog: DialogUtils.dummyDialogs()
        ),
        NpcEntity(
            name: "Billy Gates", type: .billy,
            position: CGPoint(x: 1417, y: 153),
            dialog: DialogUtils.billyDialogs()
        ),
        NpcEntity(
            name: "Chi Chi", type: .chichi,
            position: CGPoint(x: -165, y: 316),
            dialog: DialogUtils.chichiDialogs()
        ),
        NpcEntity(
            name: "Timmy the kid", type: .npcKid,
            position: CGPoint(x: 705, y: 645),
            dialog: DialogUtils.dummyDialogs() + [
                Dialog(
                    message: "I always play with mr. Billy at the park around here, he always come here",
                    evidence: true,
                    evidenceReward: "billy",
                    evidenceFloating: .billy
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
    
    // MARK: - Property
    var entities: [BaseEntity] = []
    private var lastUpdateTime: TimeInterval = 0
    var sceneTransaction: Span?
    private var burnSubscription: AnyCancellable?
    var evidenceGateSubscription: AnyCancellable?
    private let burnThreshold = 8
    private let openFenceThreshold = 7 // threshold to open fence npc
    private let durantFirstPosition = CGPoint(x: 193, y: 775)
    private let durantSecondPosition = CGPoint(x: 216, y: 834)
    let playerParkPosition = CGPoint(x: 1700, y: 340)
    
    private var hasFenceOpened = false
    private var hasCheckedBackyard = false

    weak var tissueMarkerNode: SKNode?
    
    var hasSpawnedFinalEvidence = false
    override func didMove(to view: SKView) {
        guard let gameSettingsViewModel = gameSettingsViewModel else { return }
        
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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSaveRequested),
            name: .saveGameRequested,
            object: nil
        )
        
        if gameSettingsViewModel.currentCutscene == 2 {
            cutScenePoliceExit()
        } else {
            // when the scene is first loaded
            self.physicsWorld.gravity = .zero
            self.playerEntity = PlayerEntity()
            self.joystickEntity = JoystickEntity(sceneSize: size)
            self.setupCamera()
            self.movementSystem = MovementSystem(joystickEntity: self.joystickEntity, playerEntity: self.playerEntity)
            self.ysortSystem = YSortSystem()
            // Pre-warmed chunks (loaded by PoliceGameScene.prepareGameScene before
            // this scene's didMove ran) registered entities while ysortSystem was
            // still nil — back-register them so their container zPosition gets
            // updated every frame.
            for entity in entities {
                ysortSystem?.register(entity)
            }
            self.joystickSystem = JoystickSystem(joystickEntity: joystickEntity, cam: cam, scene: self)
            self.setupPlayer()
            self.setupJoystick()
            self.setupNpcSystem(npcs)
            if chunkManager == nil {
                // we pre-warmed the setupbackground call from police transition scene
                self.setupBackground()
            }
            self.loadEvidenceFromSave()
            initSpan?.finish()
            self.setupEvidences()
            self.subscribeBurnState()
            self.setupInitialQuest()
            self.logSceneSentry()
            
            self.physicsWorld.contactDelegate = self
        }
    }
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .saveGameRequested, object: nil)
        burnSubscription?.cancel()
        burnSubscription = nil
        evidenceGateSubscription?.cancel()
        evidenceGateSubscription = nil
        evidenceSystem = nil
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
        followBillyPosition()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        npcSystem?.handleContactBegin(contact)
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        npcSystem?.handleContactEnd(contact)
    }
    
    
    // MARK: - Actions
    // Add an entity to the world: track it, register its components with each system.
    func register(_ entity: BaseEntity) {
        entities.append(entity)
        ysortSystem?.register(entity)
    }
    
    // cutscene first render
    func cutScenePoliceExit() {
        gameSettingsViewModel?.gameScene = "game"
        setCutscene(cutscene: 2)
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
    
    // observer for sentry
    @objc private func handleAppBackground() {
        if let transaction = sceneTransaction {
            transaction.setData(value: "User backgrounded via UIKit observer", key: "exit.reason")
            transaction.finish()
        }
        
        // Force Sentry to flush the transaction trace to the server immediately
        SentrySDK.flush(timeout: 2.0)
    }
    
    
    private func subscribeBurnState() {
        guard let vm = backpackStateViewModel else { return }
        // Apply current state immediately so a save above threshold already
        // shows burn chunks + relocated NPCs on first frame.
        applyEvidenceProgression(count: vm.collectedKeys.count)
        burnSubscription = vm.$collectedKeys
            .receive(on: DispatchQueue.main)
            .sink { [weak self] keys in
                self?.applyEvidenceProgression(count: keys.count)
            }
    }
    
    private func nextQuest() {
        Task {
            try await questStateViewModel?.recordProgress()
            gameSettingsViewModel?.currentQuest = questStateViewModel?.currentIndex ?? 0
            gameSettingsViewModel?.save()
        }
    }
    
    private func applyEvidenceProgression(count: Int) {
        let burned = count >= burnThreshold
        chunkManager?.setBurned(burned)
        tissueMarkerNode?.isHidden = burned
        relocateDurant()
        
        if count == 1 {
            // if evidence 1 found
            // at the park
            nextQuest()
        }

        if count >= 5 {
            // set billy dialog
            if let billy = npcs.first(where: { $0.type == .billy }) {
                billy.dialogComponent?.dialog = DialogUtils.billyNewDialog()
            }
        }

        if count >= 8 {
            spawnFinalEvidence()
        }
            
        if gameSettingsViewModel?.currentCutscene == 3 && !(gameSettingsViewModel?.fenceDialogShown ?? false) && count >= 7 {
            let dialogFence = { [weak self] in
                guard let self else { return }
                self.gameSettingsViewModel?.fenceDialogShown = true
                self.dialogStateViewModel?.setDialog(
                      dialog: Dialog(message: "Maybe I should check the apartment behind the cafe.", evidence: false),
                      npc: "Mr.Bones",
                      npcImage: "mrbones-idle_00"
                  ) {
                      self.nextQuest()
                      self.gameSettingsViewModel?.playerPosition = self.durantFirstPosition
                      self.setCutscene(cutscene: 3)
                  }
            }
            // Fence Cutscene
            if dialogStateViewModel?.dialog != nil {
                // if there is dialog
                dialogStateViewModel?.continuation = dialogFence
            } else {
                dialogFence()
            }
            
        }
        
        if gameSettingsViewModel?.currentCutscene == 4 && !hasCheckedBackyard && count >= 8 {
            gameSettingsViewModel?.hasCheckedBackyard = true
            if dialogStateViewModel?.dialog != nil {
                dialogStateViewModel?.continuation = {
                    self.nextQuest()
                    self.gameSettingsViewModel?.playerPosition = self.durantFirstPosition
                    self.setCutscene(cutscene: 4)
                }
            }               
        }
    }
    
    private func relocateDurant() {
        // npc on the fence area
        guard let gameSettingsViewModel else { return }
        guard let npc = npcSystem?.npc(withId: 3) else { return }
        
        let target = gameSettingsViewModel.numOfEvidence >= openFenceThreshold
        ? durantSecondPosition
        : durantFirstPosition
        if npc.node?.position != target {
            npc.node?.position = target
            npc.position = target
        }
    }
    
    private func loadEvidenceFromSave() {
        guard let gameSettingsViewModel else { return }
        gameSettingsViewModel.collectedEvidence.forEach {
            backpackStateViewModel?.collect($0)
        }
    }
    
    private func followBillyPosition() {
        guard let questStateViewModel = questStateViewModel else { return }
        guard questStateViewModel.currentIndex == 5  else { return } // guard if only "follow billy"
        guard let node = playerEntity?.node else { return }
        
        let billyPosition = CGPoint(x: 1250.5548095703125, y: 298.858154296875)
        
        if abs(node.position.x - billyPosition.x) < 50 {
            // only need to know x position
            Task {
                try await questStateViewModel.recordProgress()
                gameSettingsViewModel?.playerPosition = playerParkPosition
                gameSettingsViewModel?.currentQuest = questStateViewModel.currentIndex
                gameSettingsViewModel?.save()
            }
        }
    }
}
