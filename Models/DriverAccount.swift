import Foundation
import SwiftData

/// Model voor bezorger accounts
/// Gedeeld tussen klanten-app en bezorger-app
@Model
final class DriverAccount {
    @Attribute(.unique) var email: String
    var passwordHash: String // In productie: gebruik altijd gehashte wachtwoorden
    var driverName: String
    var phoneNumber: String
    var vehicleType: String // "bike", "car", "van"
    var isActive: Bool
    var createdAt: Date
    
    init(
        email: String,
        passwordHash: String,
        driverName: String,
        phoneNumber: String,
        vehicleType: String = "bike",
        isActive: Bool = true
    ) {
        self.email = email
        self.passwordHash = passwordHash
        self.driverName = driverName
        self.phoneNumber = phoneNumber
        self.vehicleType = vehicleType
        self.isActive = isActive
        self.createdAt = Date()
    }
}

