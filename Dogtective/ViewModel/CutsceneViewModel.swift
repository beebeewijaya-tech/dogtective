//
//  CutsceneViewModel.swift
//  Dogtective
//
//  Created by Bee Wijaya on 18/05/26.
//

import Combine


class CutsceneViewModel: ObservableObject {
    @Published var cutscene: Int = 0
    @Published var cutsceneName: String = ""
    
    func setCutscene(cutscene: Int) {
        self.cutscene = cutscene
        self.cutsceneName = "cutscene_\(cutscene)"
    }
    
    func incrementCutscene() {
        self.cutscene += 1
        self.cutsceneName = "cutscene_\(self.cutscene)"
    }
}
