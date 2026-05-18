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
    var currentQuest: Int
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
        currentQuest: Int = 0,
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
        self.currentQuest = currentQuest
        self.soundEnabled = soundEnabled
        self.hapticsEnabled = hapticsEnabled
        self.currentLevel = currentLevel
        self.currentCutscene = currentCutscene
        self.gameScene = gameScene
        self.collectedEvidence = collectedEvidence
    }
}
