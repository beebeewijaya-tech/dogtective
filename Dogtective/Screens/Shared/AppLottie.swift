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
    var freezeAtEnd: Bool
    var isTransparent: Bool
    var action: () -> Void
    
    init(avatarName: String, freezeAtEnd: Bool = false, isTransparent: Bool = false, action: @escaping () -> Void = {}) {
        self.avatarName = avatarName
        self.freezeAtEnd = freezeAtEnd
        self.isTransparent = isTransparent
        self.action = action
    }
    
    var body: some View {
        ZStack {

            if !isTransparent {
                Color.black
            }
            
            if freezeAtEnd {

                LottieView(animation: .named(avatarName))
                    .playbackMode(.paused(at: .progress(1.0)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {

                LottieView(animation: .named(avatarName))
                    .playing()
                    .animationDidFinish { completed in
                        action()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .ignoresSafeArea(isTransparent ? [] : .all)
    }
}
