import SwiftUI
import SwiftData

struct DriverLoginView: View {
    private enum Field: Hashable {
        case email
        case password
    }

    @Environment(\.modelContext) private var modelContext
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @FocusState private var focusedField: Field?
    @State private var activeSession: DriverSession?

    var body: some View {
        Group {
            if let session = activeSession {
                DriverDashboardView(session: session, onLogout: logout)
            } else {
                loginInterface
            }
        }
        .alert("Inloggen", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .task {
            do {
                try ensureSeedData()
                focusedField = .email
            } catch {
                alertMessage = error.localizedDescription
                showAlert = true
            }
        }
        .onSubmit(submit)
        .submitLabel(.done)
    }

    private func submit() {
        guard !isLoading else { return }

        focusedField = nil

        guard isValidEmail(email) else {
            presentAlert(message: "Voer een geldig e-mailadres in.")
            return
        }

        guard password.count >= 6 else {
            presentAlert(message: "Je wachtwoord moet minimaal 6 tekens bevatten.")
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            isLoading = true
        }

        Task {
            do {
                try DriverAuthService.ensureSeeded(in: modelContext)

                let account = try DriverAuthService.authenticate(
                    email: email,
                    password: password,
                    in: modelContext
                )

                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLoading = false
                    }
                    activeSession = account
                    presentAlert(message: "Welkom terug, \(account.driverName)!")
                    resetForm()
                }
            } catch {
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isLoading = false
                    }
                    let message: String

                    if let authError = error as? DriverAuthService.AuthError {
                        message = authError.localizedDescription
                    } else {
                        message = DriverAuthService.AuthError.internalError.localizedDescription
                    }

                    presentAlert(message: message)
                }
            }
        }
    }

    private func resetForm() {
        email = ""
        password = ""
        focusedField = .email
    }

    private func presentAlert(message: String) {
        alertMessage = message
        showAlert = true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        let pattern = #"^\S+@\S+\.\S+$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    private func ensureSeedData() throws {
        try DriverAuthService.ensureSeeded(in: modelContext)
    }

    private func logout() {
        activeSession = nil
        resetForm()
        alertMessage = "Je bent uitgelogd."
        showAlert = true
    }

    private var loginInterface: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.15, blue: 0.08),
                    Color(red: 0.20, green: 0.25, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer(minLength: 32)

                DriverLogoHeader()

                VStack(spacing: 16) {
                    TextField("E-mailadres", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12))
                        )
                        .focused($focusedField, equals: .email)

                    SecureField("Wachtwoord", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(14)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12))
                        )
                        .focused($focusedField, equals: .password)
                }

                VStack(spacing: 14) {
                    Button(action: submit) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Image(systemName: "bicycle.circle.fill")
                                    .font(.title3)
                                Text("Inloggen")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.black)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.60, green: 0.85, blue: 0.60),
                                    Color(red: 0.75, green: 0.95, blue: 0.75)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .cornerRadius(14)
                    }
                    .disabled(isLoading)
                }

                Spacer()

                Text("LTL MD Bezorgers © \(Calendar.current.component(.year, from: Date()))")
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.7))
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }
}

private struct DriverLogoHeader: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.25, blue: 0.12),
                                Color(red: 0.08, green: 0.15, blue: 0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                    .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 6)

                Image(systemName: "bicycle")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.75, green: 0.95, blue: 0.75),
                                Color(red: 0.50, green: 0.75, blue: 0.50)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.35), radius: 6, x: 0, y: 4)
            }

            VStack(spacing: 4) {
                Text("LetterToLetter")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)

                Text("Bezorger App")
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.75))
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("LTL MD Bezorger login")
    }
}

#Preview {
    DriverLoginView()
}

