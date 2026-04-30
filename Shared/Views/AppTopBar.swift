import SwiftUI

// MARK: - Top bar

struct AppTopBar: View {
    let title: String
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(title)
                    .font(AppTheme.Typography.display)
                    .foregroundStyle(.white)

                Spacer()

                AvatarBadge(username: username)
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
    }
}

// MARK: - Avatar

struct AvatarBadge: View {
    let username: String

    private var initial: String {
        if username.isEmpty { return "?" }
        else { return username.prefix(1).uppercased() }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.Colors.gradientStart, AppTheme.Colors.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text(initial)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 0) {
        AppTopBar(title: "Accueil", username: "john.doe")
        AppTopBar(title: "Films", username: "Alice")
        AppTopBar(title: "Séries", username: "")
    }
    .background(AppTheme.Colors.background)
}
