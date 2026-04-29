import SwiftUI

struct XStreamLogo: View {
    var body: some View {
        VStack(spacing: 14) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: LoginTheme.buttonStart.opacity(0.5), radius: 18, y: 6)

            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    Text("X")
                        .foregroundStyle(LoginTheme.accent)
                    Text("Stream")
                        .foregroundStyle(.white)
                }
                .font(.system(size: 30, weight: .bold))

                Text("PLAYER")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(5)
                    .foregroundStyle(LoginTheme.label)
            }
        }
    }
}
