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

class QuestStateViewModel: ObservableObject {
    @Published var questList: [Quest] = [
        Quest(title: "Talked to residents", done: false, doneCondition: 3, isLoading: false),
        Quest(title: "Leave the police office", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "Find the first evidence at the park", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "Gather more evidence around the city", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "Check the backyard", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "Follow Billy to the park", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "Investigate the burned park", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "Report to the police", done: false, doneCondition: 1, isLoading: false),
    ]
    @Published var currentProgress: Int = 0
    @Published var currentIndex: Int = 0
    
    private var doneProgress: Bool = false
    
    var currentQuest: Quest? {
        guard currentIndex < questList.count else { return nil }
        return questList[currentIndex]
    }
    
    var currentQuestDisplay: String {
        guard let q = currentQuest else { return "No quest" }
        if q.doneCondition > 1 {
            return "\(q.title) (\(currentProgress)/\(q.doneCondition))"
        }
        return q.title
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
