//
//  MoneyTrackerApp.swift
//  MoneyTracker
//
//  Created by Elizaveta Sevruk.
//

import SwiftUI

@main
struct MoneyTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            SignIn()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
