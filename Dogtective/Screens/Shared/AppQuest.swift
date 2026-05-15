//
//  AppQuest.swift
//  Dogtective
//
//  Created by Bee Wijaya on 15/05/26.
//

import SwiftUI

struct AppQuest: View {
    @Binding var quest: Quest?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let quest {
                if quest.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(quest.done ? "✓" : quest.title)
                        .foregroundStyle(.white)
                        .font(.caption)
                        .bold()
                        .animation(.easeInOut(duration: 0.3), value: quest.done)
                }
            }
        }
        .progressViewStyle(.circular)
        .padding()
        .background(Color("SecondaryColor").opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
