import SwiftUI

struct LoginFormField<Content: View>: View {
    let label: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(LoginTheme.label)
            content()
        }
    }
}
