//
//  DriverApp.swift
//  LTLL
//
//  Created by Sara Jamai on 11/11/2025.
//
//  BELANGRIJK: Deze app heeft twee @main entry points:
//  - LTLLApp.swift: Voor de klant-app (advocatenkantoren, etc.)
//  - DriverApp.swift: Voor de bezorger-app
//
//  Om tussen de apps te schakelen:
//  1. Comment de @main regel uit in LTLLApp.swift
//  2. Zorg dat @main actief is in DriverApp.swift
//
//  In de toekomst kunnen deze worden gecombineerd in één app met een app-selector
//  of als aparte targets in Xcode.

import SwiftUI
import SwiftData

// Uncomment de regel hieronder en comment @main in LTLLApp.swift uit om de bezorger-app te gebruiken
@main
struct DriverApp: App {
    @State private var modelContainer: ModelContainer?
    
    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                DriverLoginView()
                    .environment(\.modelContainer, container)
            } else {
                ProgressView("Database initialiseren...")
                    .task {
                        do {
                            let container = try await DatabaseService.createSharedContainer()
                            await MainActor.run {
                                modelContainer = container
                            }
                            // Check CloudKit status
                            await DatabaseService.checkCloudKitStatus()
                        } catch {
                            print("❌ Fatal error: Could not create database container: \(error)")
                        }
                    }
            }
        }
    }
}

