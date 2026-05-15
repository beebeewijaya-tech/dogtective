//
//  AppDialog.swift
//  Dogtective
//
//  Created by Bee Wijaya on 14/05/26.
//

import SwiftUI

struct AppDialog: View {
    var name: String
    var text: String
    @Binding var isDialogAnimate: Bool
    var action: () -> Void = {}
    
    // MARK: - State
    @State var nameDisplay: String = ""
    @State var textDisplay: String = ""

    private func animateName() async {
        for n in name.uppercased() {
            nameDisplay += String(n)
            try? await Task.sleep(for: .milliseconds(50))
        }
    }
    
    private func animateText() async {
        for t in text.capitalized {
            textDisplay += String(t)
            try? await Task.sleep(for: .milliseconds(30))
        }
        isDialogAnimate = true
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Image("dialog_head_bubble")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 37)
                        .overlay(alignment: .center) {
                            Text(isDialogAnimate ? nameDisplay : name.uppercased())
                                .foregroundStyle(.white)
                                .passerOneStyle(size: 24)
                        }
                        .offset(x: 20, y: 30)
                        .zIndex(1)
                    
                    Image("dialog_text_bubble")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .overlay {
                            VStack(alignment: .leading) {
                                Text(isDialogAnimate ? textDisplay : text.capitalized)
                                    .foregroundStyle(.black)
                                    .font(.default)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                        }
                        .onTapGesture {
                            action()
                        }
                }
            }
        }
        .task {
            await animateName()
            await animateText()
        }
    }
}
