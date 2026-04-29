import SwiftUI

struct ConnectButton: View {
    var isLoading: Bool
    var isEnabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 10) {
                        Image(systemName: "forward.end.fill")
                            .font(.system(size: 14, weight: .bold))
                        Text("Se connecter")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(ConnectButtonStyle(isEnabled: isEnabled && !isLoading))
        .disabled(!isEnabled || isLoading)
    }
}

private struct ConnectButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: isEnabled
                                ? [LoginTheme.buttonStart, LoginTheme.buttonEnd]
                                : [LoginTheme.fieldBg, LoginTheme.fieldBg],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .brightness(configuration.isPressed && isEnabled ? -0.12 : 0)
                    .shadow(
                        color: isEnabled
                            ? LoginTheme.buttonStart.opacity(configuration.isPressed ? 0.2 : 0.4)
                            : .clear,
                        radius: 16,
                        x: 0,
                        y: 4
                    )
                    .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            }
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}
