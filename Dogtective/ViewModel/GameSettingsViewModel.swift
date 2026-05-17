//
//  GameSettingsViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 17/05/26.
//

import Combine
import SwiftUI
import SwiftData

class GameSettingsViewModel: ObservableObject {
    // MARK: - Model
    private var context: ModelContext?
    
    
    // MARK: - State
    @Published var isFirstTime: Bool = true
    @Published var playerPosition: CGPoint = .zero
    @Published var numOfEvidence: Int = 0
    @Published var currentQuest: Quest? = nil
    @Published var soundEnabled: Bool = true
    @Published var hapticsEnabled: Bool = true
    @Published var currentLevel: Int = 0
    
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
        currentQuest = Quest(
            title: settings.questTitle,
            done: settings.questDone,
            doneCondition: settings.questDoneCondition,
            isLoading: false
        )
        soundEnabled = settings.soundEnabled
        hapticsEnabled = settings.hapticsEnabled
        currentLevel = settings.currentLevel
        print("load settings isFirstTime: \(isFirstTime)")
        print("load settings playerPosition: \(playerPosition)")
        print("load settings numOfEvidence: \(numOfEvidence)")
        print("load settings currentQuest: \(currentQuest)")
        print("load settings soundEnabled: \(soundEnabled)")
        print("load settings soundEnabled: \(hapticsEnabled)")
        print("load settings currentLevel: \(currentLevel)")
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
        settings.questTitle = currentQuest?.title ?? ""
        settings.questDone = currentQuest?.done ?? false
        settings.questDoneCondition = currentQuest?.doneCondition ?? 0
        settings.currentLevel = currentLevel
        try? context.save()
    }
    
    func reset() {
        guard let context else { return }
        
        let descriptor = FetchDescriptor<GameSettings>()
        if let existing = try? context.fetch(descriptor).first {
            context.delete(existing)
            try? context.save()
        }
        
        isFirstTime = true
        playerPosition = .zero
        numOfEvidence = 0
        currentQuest = nil
        soundEnabled = true
        hapticsEnabled = true
        currentLevel = 0
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
