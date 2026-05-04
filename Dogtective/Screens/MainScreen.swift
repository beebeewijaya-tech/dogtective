//
//  MainScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

struct MainScreen: View {
    @StateObject var pageStateViewModel: PageStateViewModel = PageStateViewModel()
    
    var body: some View {
        VStack {
            switch pageStateViewModel.state {
            case .home:
                HomeScreen()
            case .game:
                GameScreen()
            }
        }
        .environmentObject(pageStateViewModel)
    }
}
