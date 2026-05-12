//
//  AppIcon.swift
//  Dogtective
//
//  Created by Bee Wijaya on 07/05/26.
//

import SwiftUI

enum IconSize {
    case small, medium, large
    
    var iconSize: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 50
        case .large: return 60
        }
    }
}

struct AppIcon: View {
    var icon: String
    var size: IconSize
    var action: () -> Void
    
    var body: some View {
        Image(icon)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.iconSize, height: size.iconSize)
            .shadow(radius: 10)
            .onTapGesture {
                action()
            }
    }
}
