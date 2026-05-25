//
//  LevelViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 22/05/26.
//

import SwiftUI
import Combine

// MARK: - Level Info
struct LevelData: Identifiable {
    let id: Int
    let title: String
    let description: String
    let quest: [Quest]
    var finished: Bool
    var enabled: Bool
    var started: Bool
}


class LevelViewModel: ObservableObject {
    @Published var currentLevel: Int?
    @Published var levelData: [LevelData] = []
    
    init() {
        self.levelData = [
            LevelData(id: 1, title: "The Missing Bones", description: "Something happens in a quiet sunny days in Pawland district. Bones that are safely kept are suddenly missing...", quest: [
                Quest(title: "Talked to residents", done: false, doneCondition: 3, isLoading: false),
                Quest(title: "Leave the police office", done: false, doneCondition: 1, isLoading: false),
                Quest(title: "Find the first evidence at the park", done: false, doneCondition: 1, isLoading: false),
                Quest(title: "Gather more evidence around the city", done: false, doneCondition: 1, isLoading: false),
                Quest(title: "Check the backyard", done: false, doneCondition: 1, isLoading: false),
                Quest(title: "Follow Billy to the park", done: false, doneCondition: 1, isLoading: false),
                Quest(title: "Investigate the burned park", done: false, doneCondition: 1, isLoading: false),
                Quest(title: "Report to the police", done: false, doneCondition: 1, isLoading: false),
            ], finished: false, enabled: true, started: false),
            LevelData(id: 2, title: "The Barking Ghost", description: "Rumors say a spooky figure is haunting the backyard. It's time to investigate what's really going on!", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 3, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 4, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 5, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 6, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 7, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 8, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 9, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false),
            LevelData(id: 10, title: "Slippery Tracks", description: "Mysterious wet paw prints lead towards the pond. Is someone trying to hide something underwater?", quest: [], finished: false, enabled: false, started: false)
        ]
    }
    
    func getCurrentLevel() -> LevelData? {
        guard let currentLevel else { return nil }
        return levelData.first(where: { $0.id == currentLevel })
    }
    
    func getLevelById(id: Int) -> LevelData {
        return levelData.first(where: { $0.id == id })!
    }
    
    func getQuests() -> [Quest]? {
        return self.getCurrentLevel()?.quest
    }
    
    func setFinished(ids: [Int]) {
        for id in ids {
            guard let index = levelData.firstIndex(where: { $0.id == id}) else { continue }
            self.levelData[index].finished = true
        }
    }
    
    func startLevel(id: Int) {
        for i in levelData.indices {
            levelData[i].started = false
        }
        
        guard let index = levelData.firstIndex(where: { $0.id == id}) else { return  }
        self.levelData[index].started = true
    }
}
