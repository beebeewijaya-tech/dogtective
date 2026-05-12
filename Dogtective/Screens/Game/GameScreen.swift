//
//  GameScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import SpriteKit

struct GameScreen: View {
    @EnvironmentObject var minimapStateViewModel: MinimapStateViewModel
    
    func makeScene(size: CGSize) -> SKScene {
        let scene = PoliceGameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        return scene
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                SpriteView(scene: makeScene(size: geo.size))
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
