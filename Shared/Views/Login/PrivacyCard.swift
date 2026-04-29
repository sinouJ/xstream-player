import SwiftUI

struct PrivacyCard: View {
    var body: some View {
        Text("Vos données restent sur votre infrastructure.")
            .font(.system(size: 13))
            .foregroundStyle(LoginTheme.muted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.bottom, 28)
            .padding(.top, 60)
    }
}
