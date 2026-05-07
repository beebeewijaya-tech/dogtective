//
//  AppColor.swift
//  Dogtective
//
//  Created by Bee Wijaya on 07/05/26.
//

import SwiftUI


enum ColorState {
    case primary, secondary, tertiary
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color("PrimaryColor")
        case .secondary:
            return Color("SecondaryColor")
        case .tertiary:
            return Color("TertiaryColor")
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return Color.white
        case .secondary:
            return Color.white
        case .tertiary:
            return Color.black
        }
    }
}
