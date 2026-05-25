//
//  GameScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import SpriteKit
import SentrySwiftUI

struct GameScreen: View {
    // MARK: - ViewModel
    @EnvironmentObject var minimapStateViewModel: MinimapStateViewModel
    @EnvironmentObject var dialogStateViewModel: DialogStateViewModel
    @EnvironmentObject var questStateViewModel: QuestStateViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    @EnvironmentObject var backpackStateViewModel: BackpackStateViewModel
    @EnvironmentObject var cutsceneViewModel: CutsceneViewModel
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    @EnvironmentObject var levelViewModel: LevelViewModel

    // MARK: - State
    @State var scene: SKScene?
    @State var isDialogAnimate: Bool = true
    @State private var isPaused = false
    @State private var showSaveToast = false
    @State private var toastMessage = ""
    private let audioManager = AudioManager.shared
    private var toastDefaultMessage = "GAME SAVED!"
    
    func policeGameScene(size: CGSize) -> SKScene {
        let scene = PoliceGameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        scene.dialogStateViewModel = dialogStateViewModel
        scene.questStateViewModel = questStateViewModel
        scene.gameSettingsViewModel = gameSettingsViewModel
        scene.backpackStateViewModel = backpackStateViewModel
        scene.cutsceneViewModel = cutsceneViewModel
        scene.pageStateViewModel = pageStateViewModel
        scene.levelViewModel = levelViewModel
        return scene
    }
    
    func gameScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        scene.dialogStateViewModel = dialogStateViewModel
        scene.questStateViewModel = questStateViewModel
        scene.gameSettingsViewModel = gameSettingsViewModel
        scene.backpackStateViewModel = backpackStateViewModel
        scene.cutsceneViewModel = cutsceneViewModel
        scene.pageStateViewModel = pageStateViewModel
        scene.levelViewModel = levelViewModel
        return scene
    }
    
    func makeScene(size: CGSize) -> SKScene {
        var scene: SKScene
        if gameSettingsViewModel.gameScene == "police" {
            scene = policeGameScene(size: size)
        } else {
            scene = gameScene(size: size)
        }
        
        return scene
    }
    
    var body: some View {
        ZStack {
            if gameSettingsViewModel.isFirstTime {
                // render tutorial page
                Image("tutorial_first")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onTapGesture {
                        
                        audioManager.playSFX(
                            fileName: "selectmenu_sound",
                            isSoundEnabled: gameSettingsViewModel.soundEnabled
                        )
                        
                        gameSettingsViewModel.isFirstTime = false
                        gameSettingsViewModel.save()
                    }
            } else {
                // render game page
                GeometryReader { geo in
                    SpriteView(
                        scene: scene ?? SKScene(),
                        options: [.ignoresSiblingOrder],
                    )
                    .saturation(0.8)
                    .onAppear {
                        guard scene == nil else { return }
                        scene = makeScene(size: geo.size)
                    }
                    .onDisappear {
                      scene = nil   // explicitly drop the reference
                    }
                }
                .ignoresSafeArea(.all)
                LinearGradient(colors: [.clear, .black.opacity(0.5)], startPoint: .center, endPoint: .bottom)
                    .ignoresSafeArea(.all)
                    .allowsHitTesting(false)
                    .zIndex(1)
                
                if dialogStateViewModel.dialog != nil {
                    AppDialog(
                        name: dialogStateViewModel.npc ?? "",
                        text: dialogStateViewModel.dialog?.message ?? "",
                        image: dialogStateViewModel.npcImage
                    ) {
                        // Capture evidence payload before resetting the dialog,
                        let reward = dialogStateViewModel.dialog?.evidenceReward
                        let floating = dialogStateViewModel.dialog?.evidenceFloating
                        let collectedMsg = dialogStateViewModel.dialog?.collectedMessage
                        dialogStateViewModel.resetDialog()
                        dialogStateViewModel.isChat = .bubble
                        
                        if let reward = reward {
                            var userInfo: [String: Any] = [
                                EvidenceFromDialogKey.reward: reward
                            ]
                            if let floating = floating {
                                userInfo[EvidenceFromDialogKey.floatingType] = floating
                            }
                            if let msg = collectedMsg {
                                userInfo[EvidenceFromDialogKey.collectedMessage] = msg
                            }
                            NotificationCenter.default.post(
                                name: .evidenceFromDialog,
                                object: nil,
                                userInfo: userInfo
                            )
                        } else {
                            NotificationCenter.default.post(
                                name: .dialogDismissedNoReward,
                                object: nil
                            )
                        }
                    }
                    .zIndex(3)
                }
                // Game HUD
                VStack {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            ZStack {
                                ForEach(MinimapState.allCases, id: \.self) { state in
                                    Image(state.minimapState)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .opacity(minimapStateViewModel.state == state ? 1 : 0)
                                }
                            }
                            .frame(width: 100, height: 100)
                            
                            // Quest UI under the minimap
                            if questStateViewModel.currentQuest != nil {
                                AppQuest(questDisplay: questStateViewModel.currentQuestDisplay, quest: questStateViewModel.currentQuest)
                            }
                        }
                        Spacer()
                        
                        GameMenu(isPaused: $isPaused)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        GameActionButton()
                    }
                }
                .zIndex(2)
                .padding(.vertical, 20)
                
                if showSaveToast {
                    VStack {
                        Text(toastMessage)
                            .passerOneStyle(size: 24)
                            .tracking(-1)
                            .foregroundColor(Color(red: 235/255, green: 181/255, blue: 107/255))
                            .shadow(color: Color(red: 65/255, green: 35/255, blue: 18/255), radius: 1, x: 1.5, y: 1.5)
                            .shadow(color: Color(red: 65/255, green: 35/255, blue: 18/255), radius: 1, x: -1.5, y: -1.5)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 30)
                            .background(

                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 65/255, green: 35/255, blue: 18/255))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 235/255, green: 181/255, blue: 107/255), lineWidth: 3)
                                    )
                            )
                            .shadow(radius: 5)
                            .padding(.top, 30) 
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(90)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSaveToast = false
                            }
                        }
                    }
                }
                
                if isPaused {
                    GamePause(isPaused: $isPaused, showSaveToast: $showSaveToast)
                }
            }
        }
        .onChange(of: questStateViewModel.currentQuest?.title ?? "") { oldValue, newValue in
            if newValue != oldValue {
                Task {
                    toastMessage = newValue
                    showSaveToast = true
                    try? await Task.sleep(for: .seconds(2))
                    toastMessage = toastDefaultMessage
                    showSaveToast = false
                }
            }
        }
        .onChange(of: gameSettingsViewModel.soundEnabled) { oldValue, newValue in
            if !newValue {
                audioManager.stopAllSounds()
                audioManager.stopMusic()
            } else {
                audioManager.playMusic(fileName: "dogtective_song")
            }
        }
        .onAppear {
            toastMessage = toastDefaultMessage
        }
        .sentryTrace("Game Screen")
    }
}
