//
//  CutsceneViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import Combine


class CutsceneViewModel: ObservableObject {
    @Published var cutsceneName: String = ""
    
    func setCutscene(cutsceneName: String) {
        self.cutsceneName = cutsceneName
    }
}
