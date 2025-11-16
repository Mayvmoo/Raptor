import Foundation
import SwiftData

/// Model voor bezorgopdrachten
/// Gedeeld tussen klanten-app en bezorger-app
@Model
final class DeliveryOrder {
    @Attribute(.unique) var orderId: String
    var senderName: String
    var senderAddress: String
    var destinationName: String?
    var destinationAddress: String
    var deliveryMode: String
    var status: String // "pending", "assigned", "inProgress", "completed", "cancelled"
    var assignedDriverEmail: String?
    var isUrgent: Bool
    var notes: String?
    var attachmentImageData: Data?
    var paymentStatus: String? // "paid", "pending", "unpaid"
    var createdAt: Date
    var updatedAt: Date
    
    init(
        orderId: String = UUID().uuidString,
        senderName: String,
        senderAddress: String,
        destinationName: String? = nil,
        destinationAddress: String,
        deliveryMode: String,
        isUrgent: Bool = false,
        notes: String? = nil,
        status: String = "pending",
        attachmentImageData: Data? = nil,
        paymentStatus: String? = nil
    ) {
        self.orderId = orderId
        self.senderName = senderName
        self.senderAddress = senderAddress
        self.destinationName = destinationName
        self.destinationAddress = destinationAddress
        self.deliveryMode = deliveryMode
        self.status = status
        self.assignedDriverEmail = nil
        self.isUrgent = isUrgent
        self.notes = notes
        self.attachmentImageData = attachmentImageData
        self.paymentStatus = paymentStatus
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}

