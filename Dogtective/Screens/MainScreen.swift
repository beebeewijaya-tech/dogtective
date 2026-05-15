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
    @StateObject var questDialogViewModel: QuestStateViewModel = QuestStateViewModel()

    var body: some View {
        VStack {
            switch pageStateViewModel.state {
            case .home:
                HomeScreen()
            case .level:
                LevelScreen()
            case .loading:
                LoadingScreen()
            case .game:
                GameScreen()
                    .environmentObject(minimapStateViewModel)
                    .environmentObject(dialogStateViewModel)
                    .environmentObject(questDialogViewModel)
            }
        }
        .environmentObject(pageStateViewModel)
    }
}
