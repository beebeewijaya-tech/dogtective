//
//  AppButton.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

enum ButtonSize {
    case small, medium, large
    
    var labelSize: CGFloat {
        switch self {
        case .small: return 30
        case .medium: return 40
        case .large: return 50
        }
    }
    
    var backgroundSize: CGFloat {
        switch self {
        case .small: return 40
        case .medium: return 50
        case .large: return 60
        }
    }
    
    var outerSize: CGFloat {
        switch self {
        case .small: return 50
        case .medium: return 70
        case .large: return 90
        }
    }
}


struct AppButton: View {
    // TODO: implement button components
    var body: some View {
        Text("Hello, World!")
    }
}

struct ImageButton: View {
    var label: String
    var type: ColorState
    var size: ButtonSize
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                VStack {
                    Image(label)
                        .resizable()
                        .frame(width: size.labelSize, height: size.labelSize)
                        .foregroundStyle(type.foregroundColor)
                }
                .frame(width: size.backgroundSize, height: size.backgroundSize)
                .padding()
                .background(type.backgroundColor)
                .clipShape(Circle())
                .shadow(radius: 20)
            }
            .frame(width: size.outerSize, height: size.outerSize)
            .padding()
            .background(Color.black.opacity(0.3))
            .clipShape(Circle())
            .shadow(radius: 20)
        }

    }
}
