import SwiftUI

struct LoginView: View {
    @Environment(AppState.self) private var appState

    @State private var scheme = "https"
    @State private var serverHost = ""
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            LoginTheme.background.ignoresSafeArea()

            RadialGradient(
                colors: [LoginTheme.accent.opacity(0.18), .clear],
                center: .init(x: 0.5, y: 0.18),
                startRadius: 0,
                endRadius: 380
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    XStreamLogo()

                    Spacer().frame(height: 48)

                    VStack(spacing: 20) {
                        LoginFormField(label: "SERVEUR JELLYFIN") {
                            SchemeURLField(scheme: $scheme, host: $serverHost)
                        }

                        LoginFormField(label: "IDENTIFIANT") {
                            LoginTextField(placeholder: "nom d'utilisateur", text: $username)
                                #if os(iOS)
                                .textContentType(.username)
                                #endif
                        }

                        LoginFormField(label: "MOT DE PASSE") {
                            SecureToggleField(text: $password)
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.callout)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 12)
                    }

                    Spacer().frame(height: 24)

                    ConnectButton(isLoading: isLoading, isEnabled: canSubmit) {
                        Task { await login() }
                    }

                    Spacer().frame(height: 16)

                    Spacer().frame(height: 40)

                    PrivacyCard()

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
        .tint(LoginTheme.accent)
    }

    private var canSubmit: Bool {
        !serverHost.isEmpty && !username.isEmpty && !password.isEmpty
    }

    private func login() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        guard let serverUrl = URL(string: "\(scheme)://\(serverHost.trimmingCharacters(in: .whitespaces))") else {
            errorMessage = "URL serveur invalide"
            return
        }
        
        do {
            let credentials = try await APIClient.shared.authenticate(
                serverUrl: serverUrl,
                username: username,
                password: password
            )
            try AuthService.shared.save(credentials)
            appState.didAuthenticate()
        } catch APIError.unauthorized {
            errorMessage = "Identifiants incorrects"
        } catch APIError.unexpectedContentType {
            errorMessage = "Le serveur ne répond pas — vérifiez l'URL"
        } catch {
            errorMessage = "Erreur : \(error.localizedDescription)"
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
