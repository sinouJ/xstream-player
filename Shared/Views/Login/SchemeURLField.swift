import SwiftUI

struct SchemeURLField: View {
    @Binding var scheme: String
    @Binding var host: String

    private let schemes = ["https", "http"]

    var body: some View {
        HStack(spacing: 0) {
            Menu {
                Picker("Scheme", selection: $scheme) {
                    ForEach(schemes, id: \.self) { s in
                        Text(s).tag(s)
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(scheme)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(LoginTheme.accent)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(LoginTheme.accent)
                }
                .padding(.horizontal, 14)
                .frame(height: 52)
                .contentShape(Rectangle())
            }

            Rectangle()
                .fill(LoginTheme.fieldBorder)
                .frame(width: 1, height: 24)

            TextField(
                "",
                text: $host,
                prompt: Text("192.168.1.10:8096").foregroundStyle(LoginTheme.muted)
            )
            .foregroundStyle(.white)
            .font(.system(size: 15))
            .tint(LoginTheme.accent)
            .padding(.horizontal, 14)
            .frame(height: 52)
            #if os(iOS)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            #endif
        }
        .background(LoginTheme.fieldBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LoginTheme.fieldBorder, lineWidth: 1)
        )
    }
}
