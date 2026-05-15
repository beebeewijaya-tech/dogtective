//
//  GameMenu.swift
//  Dogtective
//
//  Created by Bee Wijaya on 07/05/26.
//

import SwiftUI

struct GameMenu: View {
    
    @State private var isBackpackOpen = false
    
    let backpackItems = [
        "tissue_off", "siluet_off", "corn_off", "piececorn_off",
        "fur_off", "dig_off", "billy_off", "fence_off"
    ]
    
    var body: some View {
        HStack(spacing: 15) {
        
            ZStack(alignment: .trailing) {
                
        
                ZStack(alignment: .trailing) {
                    if isBackpackOpen {
                        ZStack(alignment: .trailing) {

                            Image("backpackBar")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 350, height: 45)
                                .offset(x: -5)
                            
                            HStack(spacing: 5) {
                                ForEach(backpackItems, id: \.self) { item in
                                    Image(item)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .padding(.trailing, 50)
                            .padding(.leading, 15)
                        }
                        .transition(.asymmetric(
                            insertion: .offset(x: 350),
                            removal: .offset(x: 350)
                        ))
                    }
                }
                .frame(width: 400, height: 60, alignment: .trailing)
                .clipped()
                .zIndex(1)
                
                AppIcon(icon: "backpackButton", size: .medium) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isBackpackOpen.toggle()
                    }
                }
                .padding(.trailing, 7.5)
                .offset(x: 18)
                .zIndex(2)
            }
            .frame(width: 430, height: 60, alignment: .trailing)
            
            AppIcon(icon: "pauseButton", size: .medium) {
                print("Pause tapped")
            }
        }
        
        .padding(.top, 20)
        .padding(.trailing, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
    }
}

// MARK: - Previews
struct GameMenu_Previews: PreviewProvider {
    static var previews: some View {
        GameMenu()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
