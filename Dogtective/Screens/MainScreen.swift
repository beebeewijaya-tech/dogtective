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
    @StateObject var backpackStateViewModel: BackpackStateViewModel = BackpackStateViewModel()
    @StateObject var cutsceneViewModel: CutsceneViewModel
    
    init() {
        self._pageStateViewModel = StateObject(wrappedValue: PageStateViewModel())
        self._minimapStateViewModel = StateObject(wrappedValue: MinimapStateViewModel())
        self._dialogStateViewModel = StateObject(wrappedValue: DialogStateViewModel())
        self._questDialogViewModel = StateObject(wrappedValue: QuestStateViewModel())
        self._gameSettingsViewModel = StateObject(wrappedValue: GameSettingsViewModel())
        self._cutsceneViewModel = StateObject(wrappedValue: CutsceneViewModel())
    }
    
    var body: some View {
        ZStack {
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
                case .cutscene:
                    AppLottie(avatarName: cutsceneViewModel.cutsceneName) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            pageStateViewModel.setOverlay(isActive: true)
                        }
                        
                        Task {
                            try? await Task.sleep(for: .seconds(0.25))
                            pageStateViewModel.navigateToNextState()
                            cutsceneViewModel.incrementCutscene()
                            gameSettingsViewModel.currentCutscene = cutsceneViewModel.cutscene
                            gameSettingsViewModel.save()
                            withAnimation(.easeOut(duration: 0.2)) {
                                pageStateViewModel.setOverlay(isActive: false)
                            }
                        }
                    }
                case .finished:
                    // TODO: adding finished state
                    VStack {
                        Text("Finished!")
                    }
                }
            }
            .task {
                gameSettingsViewModel.configure(context: context)
            }
            .buttonStyle(HapticButtonStyle())
            .environmentObject(pageStateViewModel)
            .environmentObject(gameSettingsViewModel)
            .environmentObject(backpackStateViewModel)
            .environmentObject(questDialogViewModel)
            .environmentObject(cutsceneViewModel)
            
            
            if pageStateViewModel.showOverlay {
                Color.black
                    .ignoresSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}
