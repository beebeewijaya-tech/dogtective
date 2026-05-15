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
    
    // MARK: - State
    @State var scene: SKScene?
    @State var isDialogAnimate: Bool = true
    
    func makeScene(size: CGSize) -> SKScene {
        let scene = PoliceGameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        scene.dialogStateViewModel = dialogStateViewModel
        return scene
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                SpriteView(scene: scene ?? SKScene())
                    .onAppear {
                        scene = makeScene(size: geo.size)
                    }
            }
            .ignoresSafeArea(.all)
            
            
            if dialogStateViewModel.dialog != nil {
                AppDialog(
                    name: dialogStateViewModel.npc ?? "",
                    text: dialogStateViewModel.dialog?.message ?? "",
                    isDialogAnimate: $isDialogAnimate
                ) {
                    if isDialogAnimate {
                        // if animate true / running
                        // click will turn off animate
                        self.isDialogAnimate = false
                    } else {
                        // if animate is already done
                        // close the dialog
                        dialogStateViewModel.resetDialog()
                        self.isDialogAnimate = true
                        dialogStateViewModel.isChat = .bubble
                    }
                }
                .zIndex(2)
            }
            
            
            VStack {
                HStack(alignment: .top) {
                    Image(minimapStateViewModel.state.minimapState)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
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
