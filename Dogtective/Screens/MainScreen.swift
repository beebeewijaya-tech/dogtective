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
    @StateObject var dialogStateViewModel: DialogStateViewModel = DialogStateViewModel()
    
    var body: some View {
        VStack {
            switch pageStateViewModel.state {
            case .home:
                LoadingScreen()
            case .level:
                LevelScreen()
            case .loading:
                LoadingScreen()
            case .game:
                GameScreen()
                    .environmentObject(minimapStateViewModel)
                    .environmentObject(dialogStateViewModel)
            }
        }
        .environmentObject(pageStateViewModel)
    }
}
