//
//  GameSettings.swift
//  Dogtective
//
//  Created by Bee Wijaya on 17/05/26.
//

import SwiftUI
import SwiftData
import SpriteKit

@Model
class GameSettings {
    var isFirstTime: Bool
    var playerPositionX: Double
    var playerPositionY: Double
    var playerNumOfEvidence: Int
    var questTitle: String
    var questDoneCondition: Int
    var questDone: Bool
    var questLoading: Bool
    var soundEnabled: Bool
    var hapticsEnabled: Bool
    var currentLevel: Int
    
    var currentCutscene: Int
    var gameScene: String
    var collectedEvidence: [String]
    
    // TODO: add list evidence to save not only playerNumOfEvidence
    
    init(
        isFirstTime: Bool = true,
        playerPositionX: Double = 0,
        playerPositionY: Double = 0,
        playerNumOfEvidence: Int = 0,
        questTitle: String = "",
        questDoneCondition: Int = 0,
        questDone: Bool = false,
        questLoading: Bool = false,
        soundEnabled: Bool = true,
        hapticsEnabled: Bool = true,
        currentLevel: Int = 0,
        currentCutscene: Int = 1,
        gameScene: String = "police", // default police
        collectedEvidence: [String] = []
    ) {
        self.isFirstTime = isFirstTime
        self.playerPositionX = playerPositionX
        self.playerPositionY = playerPositionY
        self.playerNumOfEvidence = playerNumOfEvidence
        self.questTitle = questTitle
        self.questDoneCondition = questDoneCondition
        self.questDone = questDone
        self.questLoading = questLoading
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.currentLevel = currentLevel
        self.currentCutscene = currentCutscene
        self.gameScene = gameScene
        self.collectedEvidence = collectedEvidence
    }
}
