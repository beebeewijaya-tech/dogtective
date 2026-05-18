//
//  EvidenceSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import SpriteKit
import GameplayKit


// MARK: - GameScene wiring
// Getting from upper level gamescene and wire to gamescene
extension GameScene {
    func setupEvidences() {
        let system = EvidenceSystem(
            scene: self,
            playerEntity: playerEntity,
            cam: cam,
            dialogStateViewModel: dialogStateViewModel,
            backpackStateViewModel: backpackStateViewModel,
            gameSettingsViewModel: gameSettingsViewModel
        )
        self.evidenceSystem = system

        for raw in allEvidenceConfigs().enumerated() {
            var cfg = raw.element
            cfg.id = raw.offset
            let entity = EvidenceEntity(config: cfg)
            register(entity)
            addEntity(entity, position: cfg.position)
            system.addComponent(foundIn: entity)
        }
    }

    // Placeholder list, fill
    // TODO: - Positions later, hard to debug if use real location for now
    func allEvidenceConfigs() -> [EvidenceConfig] {
        return [
            .digRawTissue(at: CGPoint(x:-525, y: 140),
                          rewardGroup: "tissue_key",
                          collectedMessage: "Tissue, hmm this must be interesting."),
            .digRawTissue(at: CGPoint(x:-485, y: 140), rewardGroup: "tissue_key"),
            .trashCan(at: CGPoint(x: -539, y: 202), collectedMessage: "CORNN???"),
            .item(.pieceOfCorn, at: CGPoint(x: -469, y: -41)),
            .item(.fur, at: CGPoint(x: -344, y: 87)),
            .digRawDig   (at: CGPoint(x: -525, y: 220), scale: 0.33),
            .item(.brokenFence, at: CGPoint(x: -374, y: 570), proximityOffset:  CGPoint(x: 0, y: 60) )
           
        ]
    }
}
