import SwiftUI

struct PulsingCircle: View {
    let color: Color
    let icon: String

    @State private var pulsing = false

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(color.opacity(pulsing ? 0 : 0.25), lineWidth: 1.5)
                    .scaleEffect(pulsing ? 2.4 : 1.0)
                    .animation(
                        .easeOut(duration: 2.2)
                            .repeatForever(autoreverses: false)
                            .delay(Double(i) * 0.7),
                        value: pulsing
                    )
                    .frame(width: 90, height: 90)
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.28), color.opacity(0.05)],
                        center: .center,
                        startRadius: 4,
                        endRadius: 45
                    )
                )
                .overlay(Circle().stroke(color.opacity(0.5), lineWidth: 1.5))
                .frame(width: 90, height: 90)

            Image(systemName: icon)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(color)
        }
        .frame(width: 210, height: 210)
        .onAppear { pulsing = true }
    }
}
