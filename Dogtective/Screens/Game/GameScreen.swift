//
//  GameScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import SpriteKit

struct GameScreen: View {
    
    func makeScene(size: CGSize) -> SKScene {
        let scene = GameScene(size: size)
        return scene
    }
    
    var body: some View {
        ZStack {
            // we will use GeometryReader for getting the actual size of viewport
            GeometryReader { geo in
                SpriteView(scene: makeScene(size: geo.size))
            }
            .ignoresSafeArea(.all)
            
            
            // TODO: Implementing HUD
        }
    }
}
