import SwiftUI

struct DriverProfileView: View {
    let session: DriverSession
    var onLogout: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                profileCard
                vehicleCard
                contactCard

                Button(role: .destructive) {
                    dismiss()
                    onLogout()
                } label: {
                    Label("Log uit", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.18), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mijn profiel")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 18) {
                avatarView
                VStack(alignment: .leading, spacing: 8) {
                    Text(session.driverName)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.semibold)
                    Text("Bezorger")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            HStack(spacing: 12) {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(.secondary)
                Text(session.email)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(22)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var avatarView: some View {
        Group {
            if let avatar = session.avatar {
                Image(uiImage: avatar)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 88, height: 88)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                session.vehicleType.tint.opacity(0.3),
                                session.vehicleType.tint.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        Image(systemName: session.vehicleType.iconName)
                            .font(.system(size: 36, weight: .medium))
                            .foregroundStyle(session.vehicleType.tint)
                    )
                    .frame(width: 88, height: 88)
            }
        }
    }

    private var vehicleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Voertuig")
                    .font(.headline)
            } icon: {
                Image(systemName: session.vehicleType.iconName)
                    .foregroundStyle(session.vehicleType.tint)
            }

            Divider()

            Label(session.vehicleType.rawValue.capitalized, systemImage: "car.fill")
                .foregroundStyle(.secondary)

            if let licensePlate = session.licensePlate, !licensePlate.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "number")
                        .foregroundStyle(.secondary)
                    Text(licensePlate)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(22)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }

    private var contactCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Contactgegevens", systemImage: "phone.fill")
                .font(.headline)

            Divider()

            HStack(spacing: 12) {
                Image(systemName: "phone.fill")
                    .foregroundStyle(.secondary)
                Text(session.phoneNumber)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
        .padding(22)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
    }
}

#Preview {
    NavigationStack {
        DriverProfileView(
            session: DriverSession(
                email: "bezorger@lettertoletter.nl",
                driverName: "Jan de Bezorger",
                phoneNumber: "+31 6 12345678",
                vehicleType: .bike
            ),
            onLogout: {}
        )
    }
}

