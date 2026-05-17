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
    @EnvironmentObject var questDialogViewModel: QuestStateViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel
    @EnvironmentObject var backpackStateViewModel: BackpackStateViewModel
    
    // MARK: - State
    @State var scene: SKScene?
    @State var isDialogAnimate: Bool = true
    
    func makeScene(size: CGSize) -> SKScene {
        let scene = PoliceGameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        scene.dialogStateViewModel = dialogStateViewModel
        scene.questDialogViewModel = questDialogViewModel
        scene.gameSettingsViewModel = gameSettingsViewModel
        scene.backpackStateViewModel = backpackStateViewModel
        return scene
    }
    
    var body: some View {
        ZStack {
            if gameSettingsViewModel.isFirstTime {
                // render tutorial page
                // TODO: Bee update the tutorial_first using new assets
                Image("tutorial_first")
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .onTapGesture {
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
                    .onAppear {
                        guard scene == nil else { return }
                        scene = makeScene(size: geo.size)
                    }
                }
                .ignoresSafeArea(.all)
                
                if dialogStateViewModel.dialog != nil {
                    AppDialog(
                        name: dialogStateViewModel.npc ?? "",
                        text: dialogStateViewModel.dialog?.message ?? ""
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
                        // All four minimap images stay mounted; we toggle opacity
                        // instead of swapping the `Image` source. SwiftUI was
                        // synchronously decoding the new asset on swap = stutter.
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
                            if questDialogViewModel.currentQuest != nil {
                                AppQuest(quest: $questDialogViewModel.currentQuest)
                            }
                        }
                        Spacer()
                        
                        // Will render top-right corner game menu
                        GameMenu()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        
                        // Will render bottom-right game action menu
                        GameActionButton()
                    }
                }
                .zIndex(2)
                .padding(.vertical, 20)
            }
        }.sentryTrace("Game Screen")
    }
}
