import SwiftUI

struct HeroCard: View {
    let item: MediaItem

    private var metadataText: String {
        [
            item.genres?.first,
            item.year.map(String.init),
            item.rating.map { String(format: "★ %.1f", $0) }
        ]
        .compactMap { $0 }
        .joined(separator: " · ")
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("À LA UNE")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(AppTheme.Colors.primary)
                    .kerning(1.5)

                Text(item.seriesName ?? item.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)

                if !metadataText.isEmpty {
                    Text(metadataText)
                        .font(AppTheme.Typography.body)
                        .foregroundStyle(.white.opacity(0.70))
                }

                actionButtons
                    .padding(.top, 6)
            }
            .padding(AppTheme.Spacing.sm)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
        .background {
            if let data = item.image, let img = Image(data: data) {
                img
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: [
                        Color(red: 0.06, green: 0.18, blue: 0.38),
                        Color(red: 0.12, green: 0.30, blue: 0.55)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(alignment: .topTrailing) {
            Text("4K HDR")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.badge))
                .padding(AppTheme.Spacing.sm)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {} label: {
                Label("Lire", systemImage: "play.fill")
                    .font(AppTheme.Typography.strong)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(AppTheme.Colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            }

            Button {} label: {
                Label("Ma liste", systemImage: "plus")
                    .font(AppTheme.Typography.strong)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            }

            Button {} label: {
                Image(systemName: "info.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .buttonStyle(.plain)
    }
}

private extension Image {
    init?(data: Data) {
        #if os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        self.init(nsImage: nsImage)
        #else
        guard let uiImage = UIImage(data: data) else { return nil }
        self.init(uiImage: uiImage)
        #endif
    }
}
