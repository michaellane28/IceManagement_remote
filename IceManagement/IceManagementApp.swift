//
//  IceManagementApp.swift
//  IceManagement
//
//  Created by Michael Lane on 4/5/24.
//

import SwiftUI

@main
struct IceManagementApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
