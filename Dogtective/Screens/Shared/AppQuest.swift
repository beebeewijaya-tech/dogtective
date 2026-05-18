//
//  AppQuest.swift
//  Dogtective
//
//  Created by Bee Wijaya on 15/05/26.
//

import SwiftUI

struct AppQuest: View {
    var questDisplay: String
    var quest: Quest?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let quest {
                if quest.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(quest.done ? "✓" : questDisplay)
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
