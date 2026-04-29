import SwiftUI

struct SecureToggleField: View {
    @Binding var text: String
    @State private var isRevealed = false

    var body: some View {
        HStack {
            Group {
                if isRevealed {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text("mot de passe").foregroundStyle(LoginTheme.muted)
                    )
                } else {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text("mot de passe").foregroundStyle(LoginTheme.muted)
                    )
                }
            }
            .foregroundStyle(.white)
            .font(.system(size: 15))
            .tint(LoginTheme.accent)

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .foregroundStyle(LoginTheme.muted)
                    .font(.system(size: 16))
                    .frame(width: 36, height: 36)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(LoginTheme.fieldBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LoginTheme.fieldBorder, lineWidth: 1)
        )
    }
}
