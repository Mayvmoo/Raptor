//
//  LTLLApp.swift
//  LTLL – Klanten-app (advocatenkantoren, etc.)
//
//  Deze file is het entry point voor de KLANTEN-APP.
//  De bezorger-app gebruikt `DriverApp.swift` als entry point.
//
//  Belangrijk:
//  - In één build mag maar één `@main` actief zijn.
//  - Voor de klanten-app: zorg dat `@main` hier AAN staat
//    en dat `@main` in `DriverApp.swift` is uitgezet (of ander target gebruikt).
//

import SwiftUI
import SwiftData

@main
struct LTLLApp: App {
    @State private var modelContainer: ModelContainer?
    
    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                CustomerRootView()
                    .environment(\.modelContainer, container)
            } else {
                ProgressView("Database initialiseren (klanten-app)...")
                    .task {
                        do {
                            let container = try await DatabaseService.createSharedContainer()
                            await MainActor.run {
                                modelContainer = container
                            }
                            await DatabaseService.checkCloudKitStatus()
                        } catch {
                            print("❌ Fatal error (klanten-app): Could not create database container: \(error)")
                        }
                    }
            }
        }
    }
}


