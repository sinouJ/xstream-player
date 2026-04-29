import SwiftUI

/// Ligne simple label + valeur — à utiliser à l'intérieur de ErrorInfoGroup
struct ErrorInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(ErrorTheme.accent.opacity(0.75))
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Card groupé avec fond rouge-teinté et bordure rouge
struct ErrorInfoGroup: View {
    let serverURL: String
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            ErrorInfoRow(label: "SERVEUR", value: serverURL)

            Rectangle()
                .fill(ErrorTheme.accent.opacity(0.25))
                .frame(height: 1)
                .padding(.horizontal, 16)

            ErrorInfoRow(label: "UTILISATEUR", value: username)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ErrorTheme.accent.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ErrorTheme.accent.opacity(0.35), lineWidth: 1)
        )
    }
}
