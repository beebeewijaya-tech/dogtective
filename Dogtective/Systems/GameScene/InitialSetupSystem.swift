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
        var npcs = npcs
        if (gameSettingsViewModel?.currentCutscene ?? 0) >= 5 {
            npcs.removeAll { $0.type == .billy }
        }
        self.npcSystem = NpcSystem(
            scene: self,
            npcs: npcs,
            playerEntity: playerEntity,
            dialogStateViewModel: dialogStateViewModel
        )
        self.npcSystem?.setup { [weak self] npc in
            self?.register(npc)
        }

        let collected = Set(gameSettingsViewModel?.collectedEvidence ?? [])
        if !collected.isEmpty {
            for npc in npcs {
                npc.dialogComponent?.removeCollectedEvidenceDialogs(collected: collected)
            }
        }
    }
    
    func setupInitialQuest() {
        questStateViewModel?.currentIndex = gameSettingsViewModel?.currentQuest ?? 0
    }
}
