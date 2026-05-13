//
//  MainScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

struct MainScreen: View {
    @StateObject var pageStateViewModel: PageStateViewModel = PageStateViewModel()
    @StateObject var minimapStateViewModel: MinimapStateViewModel = MinimapStateViewModel()
    
    var body: some View {
        VStack {
            switch pageStateViewModel.state {
            case .home:
                LevelScreen()
            case .game:
                GameScreen()
                    .environmentObject(minimapStateViewModel)
            }
        }
        .environmentObject(pageStateViewModel)
    }
}
