import SwiftUI

struct LoginTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(LoginTheme.muted))
            .foregroundStyle(.white)
            .font(.system(size: 15))
            .tint(LoginTheme.accent)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(LoginTheme.fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LoginTheme.fieldBorder, lineWidth: 1)
            )
            #if os(iOS)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            #endif
    }
}
