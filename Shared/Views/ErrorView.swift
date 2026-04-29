import SwiftUI

// MARK: - Theme

enum ErrorTheme {
    static let accent = Color(red: 0.94, green: 0.34, blue: 0.34)
}

// MARK: - AppError UI extensions

extension AppError {
    var errorCode: String {
        switch self {
        case .serverUnreachable: "ERR_CONNECTION_REFUSED"
        case .unauthorized:      "ERR_UNAUTHORIZED"
        case .timeout:           "ERR_TIMEOUT"
        case .generic:           "ERR_UNKNOWN"
        }
    }

    var title: String {
        switch self {
        case .serverUnreachable: "Serveur introuvable"
        case .unauthorized:      "Identifiants incorrects"
        case .timeout:           "Délai dépassé"
        case .generic(let msg):  msg
        }
    }

    var errorDescription: String {
        switch self {
        case .serverUnreachable:
            "Impossible de joindre le serveur. Vérifiez l'adresse, le port, et que Jellyfin est bien démarré."
        case .unauthorized:
            "Le nom d'utilisateur ou le mot de passe est invalide. Vérifiez vos informations de connexion."
        case .timeout:
            "Le serveur a mis trop de temps à répondre. Il est peut-être surchargé ou hors du réseau."
        case .generic:
            "Une erreur inattendue s'est produite."
        }
    }

    var icon: String {
        switch self {
        case .serverUnreachable: "wifi.slash"
        case .unauthorized:      "lock.slash"
        case .timeout:           "hourglass"
        case .generic:           "exclamationmark.triangle"
        }
    }

    var tips: [String] {
        switch self {
        case .serverUnreachable:
            ["Vérifier l'adresse IP et le port",
             "Contrôler que le serveur est allumé",
             "Tester depuis un navigateur"]
        case .unauthorized:
            ["Vérifier la casse du mot de passe",
             "Réinitialiser le mot de passe sur Jellyfin",
             "Contacter l'administrateur"]
        case .timeout:
            ["Vérifier votre connexion réseau",
             "Réessayer dans quelques secondes",
             "Vérifier les logs Jellyfin"]
        case .generic:
            ["Réessayer", "Redémarrer l'application"]
        }
    }
}

// MARK: - View

struct ErrorView: View {
    let error: AppError
    let serverURL: String
    let username: String
    let onRetry: () -> Void
    let onModify: () -> Void

    var body: some View {
        ZStack {
            LoginTheme.background.ignoresSafeArea()

            RadialGradient(
                colors: [ErrorTheme.accent.opacity(0.14), .clear],
                center: .init(x: 0.5, y: 0.18),
                startRadius: 0,
                endRadius: 340
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 72)

                    PulsingCircle(color: ErrorTheme.accent, icon: error.icon)

                    Spacer().frame(height: 20)

                    Text(error.errorCode)
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(1.5)
                        .foregroundStyle(ErrorTheme.accent.opacity(0.65))

                    Spacer().frame(height: 12)

                    Text(error.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Spacer().frame(height: 12)

                    Text(error.errorDescription)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 24)

                    Spacer().frame(height: 36)

                    ErrorInfoGroup(serverURL: serverURL, username: username)

                    Spacer().frame(height: 12)

                    ErrorTipsSection(tips: error.tips)

                    Spacer().frame(height: 32)

                    Button(action: onRetry) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .bold))
                            Text("Réessayer")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [LoginTheme.buttonStart, LoginTheme.buttonEnd],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(
                                    color: LoginTheme.buttonStart.opacity(0.4),
                                    radius: 16, x: 0, y: 4
                                )
                        }
                    }
                    .buttonStyle(.plain)

                    Spacer().frame(height: 16)

                    Button("Modifier les informations", action: onModify)
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.45))

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    ErrorView(
        error: .serverUnreachable,
        serverURL: "https://jellyfin.monserveur.fr",
        username: "john.doe",
        onRetry: {},
        onModify: {}
    )
    .environment(AppState())
}

