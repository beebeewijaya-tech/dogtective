//
//  LevelScreen.swift
//  Dogtective
//
//  Created by Michael David Sin on 07/05/26.
//

import SwiftUI

struct LevelScreen: View {

    let rotations: [Double] = [-5.0, 6.0, -1.0, -8.0, 5.0]
    let yOffsets: [CGFloat] = [0.0, -15.0, 5.0, 20.0, -12.0]
    
    var body: some View {
        ZStack {

            Image("paper")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack(spacing: 0) {
                    ForEach(0..<5) { index in
                        GeometryReader { geometry in
                            Image("wantedPoster")
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(1.3)
                                // Memberikan shadow tipis agar tidak terlihat gepeng
                                .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
                                // Terapkan rotasi individu
                                .rotationEffect(.degrees(rotations[index]))
                                .offset(y: yOffsets[index])
                        }
                        // Tentukan ukuran dasar untuk setiap poster container
                        // Gunakan nilai ini untuk mengatur seberapa rapat poster berjejer
                        .frame(width: 150, height: 170)
                    }
                }
                .padding(.horizontal, 10)
                
                Spacer()
            }
        }
    }
}

struct LevelScreen_Previews: PreviewProvider {
    static var previews: some View {
        LevelScreen()
    }
}
