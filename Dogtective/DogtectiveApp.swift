//
//  DogtectiveApp.swift
//  Dogtective
//
//  Created by Bee Wijaya on 04/05/26.
//

import SwiftUI
import Sentry


@main
struct DogtectiveApp: App {
    init() {
        // initialize sentry
        // for error tracing
        SentryUtils.setup()
    }
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
    }
}
