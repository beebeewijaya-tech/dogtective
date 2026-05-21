//
//  EvidenceSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import Combine
import SpriteKit
import GameplayKit

extension GameScene {
    // First evidence (tissue) gates spawning the rest.
    private static let gatingKey = "tissue"

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

        let configs = allEvidenceConfigs().enumerated().map { (offset, cfg) -> EvidenceConfig in
            var c = cfg
            c.id = offset
            return c
        }
        
        let collected = backpackStateViewModel?.collectedKeys ?? []
        let tissueFound = collected.contains(Self.gatingKey)

        for cfg in configs {
            let isGate = (cfg.reward ?? cfg.type.defaultBackpackKey) == Self.gatingKey
            if !tissueFound && !isGate { continue }
            spawnEvidence(cfg: cfg, system: system, collected: collected)
        }

        if !tissueFound, let backpack = backpackStateViewModel {
            evidenceGateSubscription = backpack.$collectedKeys
                .receive(on: DispatchQueue.main)
                .sink { [weak self] keys in
                    guard let self = self, keys.contains(Self.gatingKey) else { return }
                    let pending = configs.filter { ($0.reward ?? $0.type.defaultBackpackKey) != Self.gatingKey }
                    let collectedNow = self.backpackStateViewModel?.collectedKeys ?? []
                    for cfg in pending {
                        self.spawnEvidence(cfg: cfg, system: system, collected: collectedNow)
                    }
                    self.evidenceGateSubscription?.cancel()
                    self.evidenceGateSubscription = nil
                }
        }
    }

    @discardableResult
    private func spawnEvidence(cfg: EvidenceConfig, system: EvidenceSystem, collected: Set<String>) -> EvidenceEntity {
        let entity = EvidenceEntity(config: cfg)
        register(entity)
        addEntity(entity, position: cfg.position)
        system.addComponent(foundIn: entity)

        let isGate = (cfg.reward ?? cfg.type.defaultBackpackKey) == Self.gatingKey
        if isGate {
            tissueMarkerNode = entity.component(ofType: GKSKNodeComponent.self)?.node
        }

        if let ev = entity.evidence {
            if let reward = ev.reward, collected.contains(reward) {
                ev.markInert()
            }
        }
        return entity
    }

    func spawnFinalEvidence() {
        guard !hasSpawnedFinalEvidence else { return }
        guard let system = evidenceSystem else { return }
        let collected = backpackStateViewModel?.collectedKeys ?? []
        if collected.contains("dig_bones") { return }
        hasSpawnedFinalEvidence = true

        var cfg = EvidenceConfig.digFinal(
            at: CGPoint(x: 1649.72607421875, y: 722.70361328125),
            collectedMessage: "This is the bones that were missing. I should go to the police station"
        )
        cfg.id = 999
        spawnEvidence(cfg: cfg, system: system, collected: collected)
    }

    func allEvidenceConfigs() -> [EvidenceConfig] {
        return [
            .digRawTissue(at: CGPoint(x:1522.827880859375, y: 801.6600341796875),
                          rewardGroup: "tissue_key",
                          collectedMessage: "A tissue...? That's odd. Chichi did have a flu recently... could this be hers? I should wandering around the city"),
            .trashCan(at: CGPoint(x: 1205.1734619140625, y: 474.79693603515625), collectedMessage: "An almost-finished corn cob… hidden in the trash."),
            .item(.pieceOfCorn, at: CGPoint(x: 1491.677490234375, y: 422.1864929199219), collectedMessage: "Corn…? I’ve definitely seen this corn before. And that smell… it’s strangely familiar."),
            .item(.fur, at: CGPoint(x: 1012.4349365234375, y: -241.21438598632812), scale: 0.25, collectedMessage: "Short fur stuck on the fence… hidden behind these boxes. The culprit must have short fur", zOffset: 10),
            .digRawDig (at: CGPoint(x: -491.4983215332031, y: 796.5868530273438), scale: 0.33, rewardGroup: "dig_raw_dig_key", collectedMessage: "A very clean dig… whoever did this knew exactly what they were looking for."),
            .digRawDig (at: CGPoint(x: -1046.8846435546875, y: -500.74884033203125), scale: 0.33, rewardGroup: "dig_raw_dig_key", collectedMessage: "A very clean dig… whoever did this knew exactly what they were looking for."),
            .digRawDig (at: CGPoint(x: 1027.91455078125, y: -544.146484375), scale: 0.33, rewardGroup: "dig_raw_dig_key", collectedMessage: "A very clean dig… whoever did this knew exactly what they were looking for."),
            .item(.brokenFence, at: CGPoint(x: -374, y: 570), proximityRadius: 100, proximityOffset:  CGPoint(x: 0, y: 30), collectedMessage: "A broken fence… hidden by the bushes. If Chichi’s the culprit, she could easily slip through here."),
       ]
    }
}
