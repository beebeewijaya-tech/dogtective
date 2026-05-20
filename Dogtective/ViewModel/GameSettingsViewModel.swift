//
//  GameSettingsViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 17/05/26.
//

import Combine
import SwiftUI
import SwiftData
import SpriteKit

class GameSettingsViewModel: ObservableObject {
    // MARK: - Model
    private var context: ModelContext?
    
    
    // MARK: - State
    @Published var isFirstTime: Bool = true
    @Published var playerPosition: CGPoint = .zero
    @Published var numOfEvidence: Int = 0
    @Published var currentQuest: Int = 0
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true {
        didSet { Haptics.isEnabled = hapticsEnabled }
    }
    @Published var currentLevel: Int = 0
    @Published var currentCutscene: Int = 1
    @Published var gameScene: String = "police"
    @Published var collectedEvidence: [String] = []
    
    // MARK: - Non persist
    @Published var fenceDialogShown: Bool = false
    @Published var hasCheckedBackyard: Bool = false
    
    // MARK: - Action
    
    func configure(context: ModelContext) {
        self.context = context
        load()
    }
    
    func load() {
        guard context != nil else { return }
        
        let settings = fetchOrCreateSettings()
        isFirstTime = settings.isFirstTime
        playerPosition = CGPoint(x: settings.playerPositionX, y: settings.playerPositionY)
        numOfEvidence = settings.playerNumOfEvidence
        currentQuest = settings.currentQuest
        soundEnabled = settings.soundEnabled
        hapticsEnabled = settings.hapticsEnabled
        currentLevel = settings.currentLevel
        currentCutscene = settings.currentCutscene
        gameScene = settings.gameScene
        collectedEvidence = settings.collectedEvidence
        print("load settings isFirstTime: \(isFirstTime)")
        print("load settings playerPosition: \(playerPosition)")
        print("load settings numOfEvidence: \(numOfEvidence)")
        print("load settings currentQuest: \(currentQuest)")
        print("load settings soundEnabled: \(soundEnabled)")
        print("load settings soundEnabled: \(hapticsEnabled)")
        print("load settings currentLevel: \(currentLevel)")
        print("load settings currentCutscene: \(currentCutscene)")
        print("load settings gameScene: \(gameScene)")
        print("load settings collectedEvidence: \(collectedEvidence)")
    }
    
    func save() {
        guard let context = context else { return }
        let settings = fetchOrCreateSettings()
        settings.isFirstTime = isFirstTime
        settings.playerPositionX = playerPosition.x
        settings.playerPositionY = playerPosition.y
        settings.playerNumOfEvidence = numOfEvidence
        settings.soundEnabled = soundEnabled
        settings.hapticsEnabled = hapticsEnabled
        settings.currentQuest = currentQuest
        settings.currentLevel = currentLevel
        settings.currentCutscene = currentCutscene
        settings.gameScene = gameScene
        settings.collectedEvidence = collectedEvidence
        try? context.save()
    }
    
    func reset() {
        guard let context else { return }
               
        try? context.delete(model: GameSettings.self)
        
        isFirstTime = true
        playerPosition = .zero
        numOfEvidence = 0
        currentQuest = 0
        soundEnabled = true
        hapticsEnabled = true
        currentLevel = 0
        currentCutscene = 1
        gameScene = "police"
        collectedEvidence = []
        save()
    }
    
    private func fetchOrCreateSettings() -> GameSettings {
        let descriptor = FetchDescriptor<GameSettings>()
        if let existing = try? context?.fetch(descriptor).first {
            return existing
        }
        
        let new = GameSettings()
        context?.insert(new)
        return new
    }
}
