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
    @State var scene: SKScene?
    
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
            .padding(.vertical, 20)
        }
    }
}
