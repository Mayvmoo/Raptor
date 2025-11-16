import Foundation
import SwiftData
import CloudKit

/// Gedeelde database service voor beide apps (klant-app en bezorger-app)
/// Gebruikt CloudKit voor synchronisatie tussen apps en devices
@MainActor
struct DatabaseService {
    
    /// CloudKit container identifier - moet hetzelfde zijn voor beide apps
    static let cloudKitContainerIdentifier = "iCloud.com.lettertoletter.LTLL"
    
    /// Maakt een ModelContainer aan met CloudKit synchronisatie
    /// Deze container kan door beide apps worden gebruikt
    static func createSharedContainer() async throws -> ModelContainer {
        let schema = Schema([
            DriverAccount.self,
            DeliveryOrder.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
            
            // Seed data bij eerste opstarten (op main actor)
            await MainActor.run {
                do {
                    try seedInitialDataIfNeeded(container: container)
                } catch {
                    print("⚠️ Warning: Could not seed initial data: \(error)")
                }
            }
            
            return container
        } catch {
            print("❌ Error creating ModelContainer: \(error)")
            throw error
        }
    }
    
    /// Seed initial data als de database leeg is
    @MainActor
    private static func seedInitialDataIfNeeded(container: ModelContainer) throws {
        let context = container.mainContext
        
        // Check of er al accounts zijn
        var descriptor = FetchDescriptor<DriverAccount>()
        descriptor.fetchLimit = 1
        let existingAccounts = try context.fetch(descriptor)
        
        guard existingAccounts.isEmpty else { return }
        
        // Maak een standaard test account aan
        // In productie: verwijder dit of maak het via een admin interface
        let defaultAccount = DriverAccount(
            email: "bezorger@lettertoletter.nl",
            passwordHash: "test123", // In productie: gebruik echte hashing!
            driverName: "Test Bezorger",
            phoneNumber: "+31 6 12345678",
            vehicleType: "bike",
            isActive: true
        )
        
        context.insert(defaultAccount)
        try context.save()
        
        print("✅ Seeded initial driver account")
    }
    
    /// Check CloudKit status en synchronisatie
    static func checkCloudKitStatus() async {
        do {
            let container = CKContainer(identifier: cloudKitContainerIdentifier)
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                print("✅ CloudKit is beschikbaar en actief")
            case .noAccount:
                print("⚠️ Geen iCloud account gevonden")
            case .restricted:
                print("⚠️ CloudKit is beperkt")
            case .couldNotDetermine:
                print("⚠️ CloudKit status kon niet worden bepaald")
            case .temporarilyUnavailable:
                print("⚠️ CloudKit is tijdelijk niet beschikbaar")
            @unknown default:
                print("⚠️ Onbekende CloudKit status")
            }
        } catch {
            print("⚠️ Error checking CloudKit status: \(error)")
        }
    }
}

