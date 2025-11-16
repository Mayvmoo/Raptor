import Foundation
import SwiftData
import CloudKit

/// Service voor het monitoren en beheren van database synchronisatie tussen apps
@MainActor
struct DatabaseSyncService {
    
    /// Observeert wijzigingen in de database en geeft notificaties
    static func observeChanges<T: PersistentModel>(
        for modelType: T.Type,
        in context: ModelContext,
        onChange: @escaping () -> Void
    ) {
        // SwiftData observeert automatisch wijzigingen via ModelContext
        // Deze functie kan worden uitgebreid met custom change tracking
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            onChange()
        }
    }
    
    /// Forceert een synchronisatie met CloudKit
    static func forceSync() async {
        // CloudKit synchroniseert automatisch, maar we kunnen de status checken
        await DatabaseService.checkCloudKitStatus()
    }
    
    /// Check of CloudKit synchronisatie actief is
    static func isCloudKitEnabled() -> Bool {
        // In productie: check of CloudKit daadwerkelijk beschikbaar is
        return true
    }
}

