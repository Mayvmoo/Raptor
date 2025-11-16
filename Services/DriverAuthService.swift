import Foundation
import SwiftData

@MainActor
struct DriverAuthService {
    enum AuthError: Error, LocalizedError {
        case invalidCredentials
        case accountInactive
        case internalError

        var errorDescription: String? {
            switch self {
            case .invalidCredentials:
                return "E-mailadres of wachtwoord klopt niet."
            case .accountInactive:
                return "Je account is niet actief. Neem contact op met de beheerder."
            case .internalError:
                return "Er ging iets mis. Probeer het later opnieuw."
            }
        }
    }

    static func ensureSeeded(in context: ModelContext) throws {
        var descriptor = FetchDescriptor<DriverAccount>()
        descriptor.fetchLimit = 1
        let existing = try context.fetch(descriptor)

        guard existing.isEmpty else { return }

        let defaultAccounts: [DriverAccount] = [
            DriverAccount(
                email: "bezorger@lettertoletter.nl",
                passwordHash: "test123", // In productie: gebruik echte hashing!
                driverName: "Test Bezorger",
                phoneNumber: "+31 6 12345678",
                vehicleType: "bike",
                isActive: true
            )
        ]

        for account in defaultAccounts {
            context.insert(account)
        }

        try context.save()
        print("✅ Seeded default driver accounts")
    }

    static func authenticate(
        email: String,
        password: String,
        in context: ModelContext
    ) throws -> DriverSession {
        var descriptor = FetchDescriptor<DriverAccount>()
        descriptor.predicate = #Predicate<DriverAccount> { account in
            account.email == email
        }
        descriptor.fetchLimit = 1

        guard let account = try context.fetch(descriptor).first else {
            throw AuthError.invalidCredentials
        }

        guard account.isActive else {
            throw AuthError.accountInactive
        }

        // In productie: gebruik echte password hashing (bijv. BCrypt, Argon2)
        // Voor nu: simpele string vergelijking (NIET voor productie!)
        guard account.passwordHash == password else {
            throw AuthError.invalidCredentials
        }

        // Maak een sessie aan
        let session = DriverSession(
            email: account.email,
            driverName: account.driverName,
            phoneNumber: account.phoneNumber,
            vehicleType: VehicleType(rawValue: account.vehicleType) ?? .bike
        )

        return session
    }
}

