//
//  CutsceneSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

// MARK: - Quest related system

extension GameScene {
    func setCutscene(cutscene: Int) {
        guard let cutsceneViewModel = cutsceneViewModel else { return }
        guard let gameSettingsViewModel = gameSettingsViewModel else { return }
        guard let pageStateViewModel = pageStateViewModel else { return }
        cutsceneViewModel.setCutscene(cutscene: cutscene)
        pageStateViewModel.setState(.cutscene, nextState: .game)
        gameSettingsViewModel.save()
    }
}
