//
//  LoadingScreen.swift
//  Dogtective
//
//  Created by Michael David Sin on 13/05/26.
//

import SwiftUI
import Combine
import SpriteKit

struct LoadingScreen: View {
    // MARK: - Viewmodel
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    @EnvironmentObject var cutsceneViewModel: CutsceneViewModel
    @EnvironmentObject var gameSettingsViewModel: GameSettingsViewModel

    @State private var activePaws = 0
    @State private var navigateToGame = false
    
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image("loadingBackground")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                let dotCount = (activePaws % 3) + 1
                let dots = String(repeating: ".", count: dotCount)
                
                Text("Loading\(dots)")
                    .passerOneStyle(size: 40)
                    .foregroundColor(.black)
                    .padding(.bottom, 5)
                    .frame(width: 220, alignment: .leading)
                    .padding(.leading, 30) // Penyesuaian geser kanan
                
                Image("mainIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                
                Spacer()
                
                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        Image("pawPrints")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .offset(y: index % 2 == 0 ? 15 : -15)
                            .opacity(index < activePaws ? 1 : 0)
                            .animation(.easeIn(duration: 0.3), value: activePaws)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onReceive(timer) { _ in
            if activePaws < 6 {
                activePaws += 1
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if gameSettingsViewModel.currentCutscene == 1 {
                            // if first time
                            cutsceneViewModel.setCutscene(cutscene: 1)
                            pageStateViewModel.setState(.cutscene, nextState: .game)
                        } else {
                            gameSettingsViewModel.save()
                            pageStateViewModel.setState(.game)
                        }
                    }
                }
            }
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
