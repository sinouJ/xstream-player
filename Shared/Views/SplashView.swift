import SwiftUI

struct SplashView: View {
    @State private var logoVisible = false
    @State private var textVisible = false

    var body: some View {
        ZStack {
            LoginTheme.background.ignoresSafeArea()

            RadialGradient(
                colors: [LoginTheme.accent.opacity(0.18), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 20) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: LoginTheme.buttonStart.opacity(0.5), radius: 24, y: 8)
                    .scaleEffect(logoVisible ? 1 : 0.72)
                    .opacity(logoVisible ? 1 : 0)

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
                .offset(y: textVisible ? 0 : 10)
                .opacity(textVisible ? 1 : 0)
            }
        }
        .task {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                logoVisible = true
            }
            try? await Task.sleep(for: .milliseconds(350))
            withAnimation(.easeOut(duration: 0.45)) {
                textVisible = true
            }
        }
    }
}

#Preview {
    SplashView()
}
