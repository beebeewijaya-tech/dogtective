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
        let scene = GameScene(size: size)
        scene.minimapStateViewModel = minimapStateViewModel
        return scene
    }
    
    var body: some View {
        ZStack {
            // we will use GeometryReader for getting the actual size of viewport
            GeometryReader { geo in
                SpriteView(scene: makeScene(size: geo.size))
            }
            .ignoresSafeArea(.all)
            
                        
            VStack {
                HStack(alignment: .top) {
                    // minimap
                    Image(minimapStateViewModel.state.minimapState)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                    Spacer()
                    
                    // settings & bagpack
                    GameMenu()
                }
                Spacer()
                HStack {
                    Spacer()
                    // action menu
                    GameActionButton()
                }
            }
            .padding(.vertical, 20)
        }
    }
}
