//
//  VentureFlowApp.swift
//  VentureFlow
//
//  Created by Дионисий Коневиченко on 03.11.2025.
//

import SwiftUI

@main
struct VentureFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
