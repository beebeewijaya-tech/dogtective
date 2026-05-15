//
//  GameScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import SpriteKit

struct GameScreen: View {
    // MARK: - ViewModel
    @EnvironmentObject var minimapStateViewModel: MinimapStateViewModel
    @EnvironmentObject var dialogStateViewModel: DialogStateViewModel
    @EnvironmentObject var questDialogViewModel: QuestStateViewModel

    // MARK: - State
    @State var scene: SKScene?
    @State var isDialogAnimate: Bool = true
    
    func makeScene(size: CGSize) -> SKScene {
        let scene = PoliceGameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        scene.dialogStateViewModel = dialogStateViewModel
        scene.questDialogViewModel = questDialogViewModel
        return scene
    }
    
    var body: some View {
        ZStack {
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
                    dialogStateViewModel.resetDialog()
                    dialogStateViewModel.isChat = .bubble
                }
                .zIndex(2)
            }
            
            
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
                        
                        if questDialogViewModel.currentQuest != nil {
                            AppQuest(quest: $questDialogViewModel.currentQuest)
                        }
                    }
                    Spacer()
                    GameMenu()
                }
                Spacer()
                HStack {
                    Spacer()
                    GameActionButton()
                }
            }
            .zIndex(1)
            .padding(.vertical, 20)
        }
    }
}
