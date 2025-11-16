import Foundation
import SwiftData

/// Model voor bezorger sessies (actieve login)
/// Wordt gebruikt in de bezorger-app om de ingelogde bezorger bij te houden
@Model
final class DriverSession {
    var email: String
    var driverName: String
    var phoneNumber: String
    var vehicleType: VehicleType
    var loggedInAt: Date
    
    init(
        email: String,
        driverName: String,
        phoneNumber: String,
        vehicleType: VehicleType = .bike
    ) {
        self.email = email
        self.driverName = driverName
        self.phoneNumber = phoneNumber
        self.vehicleType = vehicleType
        self.loggedInAt = Date()
    }
}

/// Enum voor voertuigtypes
enum VehicleType: String, Codable {
    case bike = "bike"
    case car = "car"
    case van = "van"
}

