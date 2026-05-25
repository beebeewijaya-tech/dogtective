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
    @StateObject var levelViewModel: LevelViewModel
    
    init() {
        self._pageStateViewModel = StateObject(wrappedValue: PageStateViewModel())
        self._minimapStateViewModel = StateObject(wrappedValue: MinimapStateViewModel())
        self._dialogStateViewModel = StateObject(wrappedValue: DialogStateViewModel())
        self._questDialogViewModel = StateObject(wrappedValue: QuestStateViewModel())
        self._gameSettingsViewModel = StateObject(wrappedValue: GameSettingsViewModel())
        self._cutsceneViewModel = StateObject(wrappedValue: CutsceneViewModel())
        self._levelViewModel = StateObject(wrappedValue: LevelViewModel())
    }
    
    var body: some View {
        ZStack {
            VStack {
                switch pageStateViewModel.state {
                case .home:
                    HomeScreen()
                case .level, .finished:
                    LevelScreen()
                case .loading:
                    LoadingScreen()
                case .game:
                    GameScreen()
                case .cutscene:
                    AppLottie(avatarName: cutsceneViewModel.cutsceneName) {
                        withAnimation(.easeIn(duration: 0.2)) {
                            pageStateViewModel.setOverlay(isActive: true)
                        }
                        
                        Task {
                            try? await Task.sleep(for: .seconds(0.25))
                            let currentName = cutsceneViewModel.cutsceneName
                            if gameSettingsViewModel.soundEnabled {
                                if currentName == "cutscene_1" || currentName == "cutscene_4" {
                                    AudioManager.shared.fadeOutCutsceneAndResumeMusic(duration: 1.5)
                                } else {
                                    AudioManager.shared.playMusic(fileName: "dogtective_song")
                                }
                            }
                            pageStateViewModel.navigateToNextState()
                            cutsceneViewModel.incrementCutscene()
                            gameSettingsViewModel.currentCutscene = cutsceneViewModel.cutscene
                            gameSettingsViewModel.save()
                            withAnimation(.easeOut(duration: 0.2)) {
                                pageStateViewModel.setOverlay(isActive: false)
                            }
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            let currentName = cutsceneViewModel.cutsceneName
                            
                            if gameSettingsViewModel.soundEnabled {
                                if currentName == "cutscene_1" || currentName == "cutscene_4" {
                                    AudioManager.shared.playCutsceneSound(fileName: "screaming_sound", loop: 0)
                                }
                            }
                        }
                    }
                }
            }
            .task {
                gameSettingsViewModel.configure(context: context)
                levelViewModel.setFinished(ids: gameSettingsViewModel.levelFinished)
            }
            .buttonStyle(HapticButtonStyle())
            .environmentObject(pageStateViewModel)
            .environmentObject(gameSettingsViewModel)
            .environmentObject(backpackStateViewModel)
            .environmentObject(questDialogViewModel)
            .environmentObject(cutsceneViewModel)
            .environmentObject(minimapStateViewModel)
            .environmentObject(dialogStateViewModel)
            .environmentObject(levelViewModel)
            
            
            if pageStateViewModel.showOverlay {
                Color.black
                    .ignoresSafeArea(.all)
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
    }
}
