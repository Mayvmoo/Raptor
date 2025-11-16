import SwiftUI
import MapKit

struct DriverOrderDetailView: View {
    let order: DeliveryOrder
    let session: DriverSession
    var onStatusChange: () -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var showStatusUpdateAlert: Bool = false
    @State private var statusUpdateMessage: String = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                orderHeaderCard
                routeCard
                detailsCard
                statusCard
                actionButtons
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Order Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Status bijgewerkt", isPresented: $showStatusUpdateAlert) {
            Button("OK") {
                onStatusChange()
                dismiss()
            }
        } message: {
            Text(statusUpdateMessage)
        }
    }

    private var orderHeaderCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Order #\(String(order.orderId.prefix(8)))")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if order.isUrgent {
                    Label("SPOED", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.1), in: Capsule())
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var routeCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Route", systemImage: "map.fill")
                .font(.headline)

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color.blue)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ophalen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(order.senderName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text(order.senderAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                HStack {
                    Image(systemName: "arrow.down")
                        .foregroundStyle(.secondary)
                        .padding(.leading, 8)
                }

                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "paperplane.circle.fill")
                        .foregroundStyle(Color.green)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bezorgen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let destinationName = order.destinationName {
                            Text(destinationName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        Text(order.destinationAddress)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Details", systemImage: "info.circle.fill")
                .font(.headline)

            Divider()

            if let notes = order.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructies")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(notes)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }

            if order.attachmentImageData != nil {
                HStack {
                    Image(systemName: "photo.fill")
                        .foregroundStyle(.secondary)
                    Text("Brief foto beschikbaar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Status", systemImage: "clock.fill")
                .font(.headline)

            Divider()

            StatusBadge(status: order.status)
        }
        .padding(20)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if order.status == "assigned" {
                Button {
                    updateStatus(to: "inProgress")
                } label: {
                    Label("Start bezorging", systemImage: "play.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.orange,
                                    Color.orange.opacity(0.8)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                }
            }

            if order.status == "inProgress" {
                Button {
                    updateStatus(to: "completed")
                } label: {
                    Label("Markeer als voltooid", systemImage: "checkmark.circle.fill")
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
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                }
            }
        }
    }

    private func updateStatus(to newStatus: String) {
        order.status = newStatus
        
        do {
            try modelContext.save()
            statusUpdateMessage = "Order status is bijgewerkt naar \(statusText(newStatus))."
            showStatusUpdateAlert = true
        } catch {
            statusUpdateMessage = "Fout bij het bijwerken van de status: \(error.localizedDescription)"
            showStatusUpdateAlert = true
        }
    }

    private func statusText(_ status: String) -> String {
        switch status {
        case "assigned": return "Toegewezen"
        case "inProgress": return "Onderweg"
        case "completed": return "Voltooid"
        default: return status
        }
    }
}

#Preview {
    NavigationStack {
        DriverOrderDetailView(
            order: DeliveryOrder(
                senderName: "Advocatenkantoor De Vries",
                senderAddress: "Herengracht 201, 1016 BE Amsterdam",
                destinationName: "Marieke de Vries",
                destinationAddress: "Cornelis Schuytstraat 45, 1071 JL Amsterdam",
                isUrgent: true,
                notes: "Bel aan bij kantoor, 3e verdieping",
                status: "assigned"
            ),
            session: DriverSession(
                email: "bezorger@lettertoletter.nl",
                driverName: "Jan de Bezorger",
                phoneNumber: "+31 6 12345678",
                vehicleType: .bike
            ),
            onStatusChange: {}
        )
    }
}

