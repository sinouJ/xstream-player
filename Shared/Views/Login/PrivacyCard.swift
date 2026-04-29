import SwiftUI

struct PrivacyCard: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.08, green: 0.05, blue: 0.18))

            RadialGradient(
                colors: [
                    LoginTheme.buttonStart.opacity(0.7),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 220
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))

            Text("Vos données restent sur votre infrastructure.")
                .font(.system(size: 13))
                .foregroundStyle(LoginTheme.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 28)
                .padding(.top, 60)
        }
    }
}
