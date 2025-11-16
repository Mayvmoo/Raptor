//
//  RaptorApp.swift
//  Raptor
//
//  Created by Sara Jamai on 16/11/2025.
//

import SwiftUI
import SwiftData

@main
struct RaptorApp: App {
    @State private var modelContainer: ModelContainer?
    
    var body: some Scene {
        WindowGroup {
            if let container = modelContainer {
                CustomerRootView()
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
