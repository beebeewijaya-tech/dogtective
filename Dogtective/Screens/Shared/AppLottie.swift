//
//  AppLottie.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import SwiftUI
import Lottie


struct AppLottie: View {
    var avatarName: String
    var action: () -> Void = {}
    
    init(avatarName: String, action: @escaping () -> Void) {
        self.avatarName = avatarName
        self.action = action
    }
    
    var body: some View {
        ZStack {
            Color.black
            LottieView(animation: .named(avatarName))
                .playing()
                .animationDidFinish { completed in
                    action()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(.all)
    }
}
