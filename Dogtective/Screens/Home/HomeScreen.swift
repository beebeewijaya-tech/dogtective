//
//  HomeScreen.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI

struct HomeScreen: View {
    // MARK: - Viewmodel
    @EnvironmentObject var pageStateViewModel: PageStateViewModel
    
    var body: some View {
        VStack {
            // TODO: implementing landing page
            
            
            Text("Home, click me to navigate")
                .onTapGesture {
                    pageStateViewModel.setState(.game)
                }
        }
    }
}
