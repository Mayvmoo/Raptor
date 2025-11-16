import Foundation
import SwiftData

/// Gedeelde service voor orderbeheer tussen klant- en bezorger-apps
/// Deze service kan in de toekomst worden uitgebreid met API-calls naar een backend
@MainActor
struct OrderService {
    
    /// Maakt een nieuwe order aan vanuit de klant-app
    static func createOrder(
        senderName: String,
        senderAddress: String,
        destinationName: String?,
        destinationAddress: String,
        deliveryMode: String,
        isUrgent: Bool,
        notes: String?,
        attachmentImageData: Data?,
        in context: ModelContext
    ) throws -> DeliveryOrder {
        let order = DeliveryOrder(
            senderName: senderName,
            senderAddress: senderAddress,
            destinationName: destinationName,
            destinationAddress: destinationAddress,
            deliveryMode: deliveryMode,
            isUrgent: isUrgent,
            notes: notes,
            status: "pending",
            attachmentImageData: attachmentImageData
        )
        
        context.insert(order)
        try context.save()
        
        print("✅ Order aangemaakt: \(order.orderId)")
        return order
    }
    
    /// Haalt alle orders op (voor klant-app of admin)
    static func fetchAllOrders(in context: ModelContext) throws -> [DeliveryOrder] {
        let descriptor = FetchDescriptor<DeliveryOrder>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }
    
    /// Haalt orders op voor een specifieke bezorger
    static func fetchOrdersForDriver(
        driverEmail: String,
        in context: ModelContext
    ) throws -> [DeliveryOrder] {
        var descriptor = FetchDescriptor<DeliveryOrder>(
            predicate: #Predicate<DeliveryOrder> { order in
                order.assignedDriverEmail == driverEmail
            }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        return try context.fetch(descriptor)
    }
    
    /// Haalt beschikbare (pending) orders op
    static func fetchAvailableOrders(in context: ModelContext) throws -> [DeliveryOrder] {
        var descriptor = FetchDescriptor<DeliveryOrder>(
            predicate: #Predicate<DeliveryOrder> { order in
                order.status == "pending"
            }
        )
        descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
        return try context.fetch(descriptor)
    }
    
    /// Update de status van een order
    static func updateOrderStatus(
        order: DeliveryOrder,
        status: String,
        in context: ModelContext
    ) throws {
        order.status = status
        order.updatedAt = Date()
        try context.save()
    }
    
    /// Wijs een order toe aan een bezorger
    static func assignOrder(
        order: DeliveryOrder,
        driverEmail: String,
        in context: ModelContext
    ) throws {
        order.assignedDriverEmail = driverEmail
        order.status = "assigned"
        order.updatedAt = Date()
        try context.save()
    }
    
    /// Markeer een order als voltooid
    static func completeOrder(
        order: DeliveryOrder,
        in context: ModelContext
    ) throws {
        order.status = "completed"
        order.updatedAt = Date()
        try context.save()
    }
}

