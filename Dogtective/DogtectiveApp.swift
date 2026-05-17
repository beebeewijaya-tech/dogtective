//
//  DogtectiveApp.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import Sentry
import SwiftData

@main
struct DogtectiveApp: App {
    var gameModelContainer: ModelContainer
    
    init() {
        // initialize sentry
        // for error tracing
        SentryUtils.setup()
        
        // implement modelContainer
        gameModelContainer = try! ModelContainer(for: GameSettings.self)
    }
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
        .modelContainer(gameModelContainer)
    }
}
