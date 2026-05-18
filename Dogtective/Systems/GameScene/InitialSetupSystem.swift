//
//  GameSceneSetup.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import SpriteKit
import GameplayKit
import Sentry


// MARK: - Everything related to setup initial from gamescene

extension GameScene {
    func logSceneSentry() {
        let breadcrumb = Breadcrumb(level: .info, category: "gameplay.lifecycle")
        breadcrumb.message = "User entered MainGameScene exploration mode."
        SentrySDK.addBreadcrumb(breadcrumb)
    }
    
    func setupNpcSystem(_ npcs: [NpcEntity]) {
        self.npcSystem = NpcSystem(
            scene: self,
            npcs: npcs,
            playerEntity: playerEntity,
            dialogStateViewModel: dialogStateViewModel
        )
        self.npcSystem?.setup { [weak self] npc in
            self?.register(npc)
        }
    }
    
    func setupInitialQuest() {
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
    }
}
