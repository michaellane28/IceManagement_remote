//
//  IceManagementApp.swift
//  IceManagement
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
