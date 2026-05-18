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
        Quest(title: "Talked to 0/3 npcs", done: false, doneCondition: 3, isLoading: false),
        Quest(title: "Exit from the police office", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "", done: false, doneCondition: 1, isLoading: false),
        Quest(title: "", done: false, doneCondition: 1, isLoading: false),
        
    ]
    @Published var currentQuest: Quest?
    
    func setQuest(_ newQuest: Quest) {
        currentQuest = newQuest
    }
    
    func checkDone(questDone: Int) -> Bool {
        // check if the quest done
        return currentQuest?.doneCondition == questDone
    }
    
    func doneQuest(_ newQuest: Quest) async throws {
        // when done quest
        // we want to show loading
        // we want set newQuest to the user
        
        // 1. loading spinner
        currentQuest?.isLoading = true
        try await Task.sleep(for: .seconds(1))

        // 2. check mark
        setQuest(Quest(
            title: currentQuest?.title ?? "",
            done: true,
            doneCondition: currentQuest?.doneCondition ?? 0,
            isLoading: false
        ))
        try await Task.sleep(for: .seconds(1))

        setQuest(newQuest)
    }
}
