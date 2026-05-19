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
            .digRawTissue(at: CGPoint(x:1522.827880859375, y: 801.6600341796875),
                          rewardGroup: "tissue_key",
                          collectedMessage: "Tissue, hmm this must be interesting."),
            .trashCan(at: CGPoint(x: 1205.1734619140625, y: 474.79693603515625), collectedMessage: "CORNN???"),
            .item(.pieceOfCorn, at: CGPoint(x: 1491.677490234375, y: 422.1864929199219)),
            .item(.fur, at: CGPoint(x: 1012.4349365234375, y: -241.21438598632812), scale: 0.25, zOffset: 10),
            .digRawDig   (at: CGPoint(x: -491.4983215332031, y: 796.5868530273438), scale: 0.33, rewardGroup: "dig_raw_dig_key"),
            .digRawDig   (at: CGPoint(x: -1046.8846435546875, y: -500.74884033203125), scale: 0.33, rewardGroup: "dig_raw_dig_key"),
            .digRawDig   (at: CGPoint(x: 1027.91455078125, y: -544.146484375), scale: 0.33, rewardGroup: "dig_raw_dig_key"),
            .item(.brokenFence, at: CGPoint(x: -374, y: 570), proximityOffset:  CGPoint(x: 0, y: 60) )
           
        ]
    }
}
