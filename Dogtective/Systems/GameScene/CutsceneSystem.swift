//
//  CutsceneSystem.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import SwiftUI

// MARK: - Quest related system

extension GameScene {
    func setCutscene(cutscene: Int, nextPage: PageState = .game) {
        guard let cutsceneViewModel = cutsceneViewModel else { return }
        guard let gameSettingsViewModel = gameSettingsViewModel else { return }
        guard let pageStateViewModel = pageStateViewModel else { return }
        withAnimation(.easeIn(duration: 0.2)) {
            pageStateViewModel.setOverlay(isActive: true)
        }
        
        Task {
            try? await Task.sleep(for: .seconds(0.25))
            withAnimation(.easeOut(duration: 0.2)) {
                pageStateViewModel.setOverlay(isActive: false)
            }
            cutsceneViewModel.setCutscene(cutscene: cutscene)
            pageStateViewModel.setState(.cutscene, nextState: nextPage)
            gameSettingsViewModel.save()
        }
    }
}
