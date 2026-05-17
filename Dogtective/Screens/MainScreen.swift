//
//  MainScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import SwiftData

struct MainScreen: View {
    // MARK: - Model
    @Environment(\.modelContext) private var context

    // MARK: - ViewModel
    @StateObject var pageStateViewModel: PageStateViewModel
    @StateObject var minimapStateViewModel: MinimapStateViewModel
    @StateObject var dialogStateViewModel: DialogStateViewModel
    @StateObject var questDialogViewModel: QuestStateViewModel
    @StateObject var gameSettingsViewModel: GameSettingsViewModel
    
    init() {
        self._pageStateViewModel = StateObject(wrappedValue: PageStateViewModel())
        self._minimapStateViewModel = StateObject(wrappedValue: MinimapStateViewModel())
        self._dialogStateViewModel = StateObject(wrappedValue: DialogStateViewModel())
        self._questDialogViewModel = StateObject(wrappedValue: QuestStateViewModel())
        self._gameSettingsViewModel = StateObject(wrappedValue: GameSettingsViewModel())
    }

    var body: some View {
        VStack {
            switch pageStateViewModel.state {
            case .home:
                HomeScreen()
            case .level:
                LevelScreen()
            case .loading:
                LoadingScreen()
            case .game:
                GameScreen()
                    .environmentObject(minimapStateViewModel)
                    .environmentObject(dialogStateViewModel)
                    .environmentObject(questDialogViewModel)
            }
        }
        .task {
            gameSettingsViewModel.configure(context: context)
          }
        .environmentObject(pageStateViewModel)
        .environmentObject(gameSettingsViewModel)
    }
}
