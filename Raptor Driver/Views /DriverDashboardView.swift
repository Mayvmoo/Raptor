import SwiftUI
import SwiftData
import MapKit

struct DriverDashboardView: View {
    let session: DriverSession
    var onLogout: () -> Void

    @Environment(\.modelContext) private var modelContext
    @State private var availableOrders: [DeliveryOrder] = []
    @State private var myOrders: [DeliveryOrder] = []
    @State private var selectedTab: DriverTab = .available
    @State private var destination: DriverDestination?
    @State private var selectedOrder: DeliveryOrder?

    private static let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
        span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25)
    )

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .region(
        DriverDashboardView.defaultRegion
    ))

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabSelector

                if selectedTab == .available {
                    availableOrdersView
                } else {
                    myOrdersView
                }
            }
            .navigationDestination(item: $destination) { selection in
                switch selection {
                case .profile:
                    DriverProfileView(session: session, onLogout: onLogout)
                case .orderDetail(let order):
                    DriverOrderDetailView(order: order, session: session, onStatusChange: {
                        loadOrders()
                    })
                }
            }
        }
        .task {
            loadOrders()
        }
    }

    private var tabSelector: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation {
                    selectedTab = .available
                }
            } label: {
                VStack(spacing: 8) {
                    Label("Beschikbaar", systemImage: "list.bullet")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if !availableOrders.isEmpty {
                        Text("\(availableOrders.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2), in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(selectedTab == .available ? Color.green : Color.secondary)
                .background(selectedTab == .available ? Color.green.opacity(0.1) : Color.clear)
            }

            Divider()

            Button {
                withAnimation {
                    selectedTab = .myOrders
                }
            } label: {
                VStack(spacing: 8) {
                    Label("Mijn Orders", systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if !myOrders.isEmpty {
                        Text("\(myOrders.count)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.2), in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(selectedTab == .myOrders ? Color.blue : Color.secondary)
                .background(selectedTab == .myOrders ? Color.blue.opacity(0.1) : Color.clear)
            }
        }
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(.separator)),
            alignment: .bottom
        )
    }

    private var availableOrdersView: some View {
        Group {
            if availableOrders.isEmpty {
                emptyStateView(
                    icon: "tray",
                    title: "Geen beschikbare orders",
                    message: "Er zijn momenteel geen nieuwe orders beschikbaar. Check later opnieuw!"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(availableOrders) { order in
                            AvailableOrderCard(order: order) {
                                acceptOrder(order)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .safeAreaInset(edge: .top) {
            topBar
        }
    }

    private var myOrdersView: some View {
        Group {
            if myOrders.isEmpty {
                emptyStateView(
                    icon: "checkmark.circle",
                    title: "Geen actieve orders",
                    message: "Je hebt momenteel geen actieve orders. Accepteer een order om te beginnen!"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(myOrders) { order in
                            MyOrderCard(order: order) {
                                selectedOrder = order
                                destination = .orderDetail(order)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .safeAreaInset(edge: .top) {
            topBar
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                destination = .profile
            } label: {
                Label("Profiel", systemImage: "person.crop.circle")
                    .font(.subheadline)
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color.white.opacity(0.92))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
                    .foregroundStyle(Color.black.opacity(0.8))
            }

            Spacer()

            Button {
                loadOrders()
            } label: {
                Label("Ververs", systemImage: "arrow.clockwise")
                    .font(.subheadline)
                    .labelStyle(.iconOnly)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.10, green: 0.20, blue: 0.10),
                                        Color(red: 0.15, green: 0.25, blue: 0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .foregroundStyle(Color.white)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 8)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
    }

    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(Color.secondary.opacity(0.5))
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func loadOrders() {
        Task {
            do {
                var availableDescriptor = FetchDescriptor<DeliveryOrder>(
                    predicate: #Predicate { $0.status == "pending" }
                )
                availableDescriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]

                var myDescriptor = FetchDescriptor<DeliveryOrder>(
                    predicate: #Predicate { $0.assignedDriverEmail == session.email && ($0.status == "assigned" || $0.status == "inProgress") }
                )
                myDescriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]

                await MainActor.run {
                    do {
                        availableOrders = try modelContext.fetch(availableDescriptor)
                        myOrders = try modelContext.fetch(myDescriptor)
                    } catch {
                        print("Error loading orders: \(error)")
                    }
                }
            }
        }
    }

    private func acceptOrder(_ order: DeliveryOrder) {
        order.assignedDriverEmail = session.email
        order.status = "assigned"
        
        do {
            try modelContext.save()
            loadOrders()
        } catch {
            print("Error accepting order: \(error)")
        }
    }

    private enum DriverTab {
        case available
        case myOrders
    }

    private enum DriverDestination: Identifiable {
        case profile
        case orderDetail(DeliveryOrder)

        var id: String {
            switch self {
            case .profile: return "profile"
            case .orderDetail(let order): return order.orderId
            }
        }
    }
}

private struct AvailableOrderCard: View {
    let order: DeliveryOrder
    let onAccept: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(String(order.orderId.prefix(8)))")
                        .font(.headline)
                    if order.isUrgent {
                        Label("SPOED", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.red)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(order.createdAt.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if isPaid {
                        PaidBadge()
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ophalen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(order.senderAddress)
                            .font(.subheadline)
                    }
                }

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "paperplane.circle.fill")
                        .foregroundStyle(Color.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Bezorgen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(order.destinationAddress)
                            .font(.subheadline)
                    }
                }
            }

            if let notes = order.notes, !notes.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                onAccept()
            } label: {
                Label("Accepteer order", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color.white)
                    .background(
                        LinearGradient(
                            colors: [
                                Color.green,
                                Color.green.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
            }
        }
        .padding()
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    private var isPaid: Bool {
        order.paymentStatus?.lowercased() == "paid"
    }
}

private struct MyOrderCard: View {
    let order: DeliveryOrder
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Order #\(String(order.orderId.prefix(8)))")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        Label(order.senderAddress, systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Label(order.destinationAddress, systemImage: "paperplane.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        StatusBadge(status: order.status)
                        if order.isUrgent {
                            Label("SPOED", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.red)
                        }
                        if isPaid {
                            PaidBadge()
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var isPaid: Bool {
        order.paymentStatus?.lowercased() == "paid"
    }
}

private struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(statusText)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor, in: Capsule())
            .foregroundStyle(foregroundColor)
    }

    private var statusText: String {
        switch status {
        case "assigned": return "TOEGEWEZEN"
        case "inProgress": return "ONDERWEG"
        case "completed": return "VOLTOOID"
        default: return status.uppercased()
        }
    }

/// Klein label dat aangeeft dat de order al is betaald
private struct PaidBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .font(.caption2)
            Text("Betaald")
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.green.opacity(0.15), in: Capsule())
        .foregroundStyle(Color.green)
    }
}

    private var backgroundColor: Color {
        switch status {
        case "assigned": return Color.blue.opacity(0.2)
        case "inProgress": return Color.orange.opacity(0.2)
        case "completed": return Color.green.opacity(0.2)
        default: return Color.gray.opacity(0.2)
        }
    }

    private var foregroundColor: Color {
        switch status {
        case "assigned": return Color.blue
        case "inProgress": return Color.orange
        case "completed": return Color.green
        default: return Color.gray
        }
    }
}

#Preview {
    DriverDashboardView(
        session: DriverSession(
            email: "bezorger@lettertoletter.nl",
            driverName: "Jan de Bezorger",
            phoneNumber: "+31 6 12345678",
            vehicleType: .bike
        ),
        onLogout: {}
    )
}

