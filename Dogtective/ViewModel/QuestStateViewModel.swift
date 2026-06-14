//
//  QuestViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 15/05/26.
//

import Combine

struct Quest {
    var title: String
    var done: Bool
    var doneCondition: Int // condition of the quest needed to be done
    var isLoading: Bool
}

@MainActor
class QuestStateViewModel: ObservableObject {
    @Published var questList: [Quest] = []
    @Published var currentProgress: Int = 0
    @Published var currentIndex: Int = 0
    
    private var doneProgress: Bool = false
    
    var currentQuest: Quest? {
        guard currentIndex < questList.count else { return nil }
        return questList[currentIndex]
    }
    
    var isQuestLast: Bool {
        currentIndex == questList.count - 1
    }
    
    var currentQuestDisplay: String {
        guard let q = currentQuest else { return "No quest" }
        if q.doneCondition > 1 {
            return "\(q.title) (\(currentProgress)/\(q.doneCondition))"
        }
        return q.title
    }
    
    func setQuestList(_ quests: [Quest]) {
        self.questList = quests
    }
    
    func recordProgress() async throws {
        guard !doneProgress else { return }
        
        // for quest with a lot done condition
        currentProgress += 1
        print("currentProgress: \(currentProgress)")
        print("currentQuest: \(currentQuestDisplay)")

        guard let currentQuest else { return }
        guard currentProgress >= currentQuest.doneCondition else { return }
        try await doneQuest()
    }
    
    func setQuest(_ quest: Int) {
        currentIndex = quest
    }

    func reset() {
        currentIndex = 0
        currentProgress = 0
        doneProgress = false
        for i in questList.indices {
            questList[i].done = false
            questList[i].isLoading = false
        }
    }
    
    func doneQuest() async throws {
        doneProgress = true
        
        // when done quest
        // we want to show loading
        // we want set newQuest to the user
        defer {
            doneProgress = false
        }
        
        // 1. loading spinner
        questList[currentIndex].isLoading = true
        try await Task.sleep(for: .seconds(1))

        // 2. check mark
        questList[currentIndex].done = true
        questList[currentIndex].isLoading = false

        try await Task.sleep(for: .seconds(1))

        
        currentProgress = 0
        currentIndex += 1
        print("currentIndex: ", currentIndex)

    }
}
