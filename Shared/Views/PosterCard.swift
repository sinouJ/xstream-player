import SwiftUI

struct PosterCard: View {
    let item: MediaItem
    var isNew: Bool = false
    var isFocused: Bool = false
    var progressPercent: Double? = nil   // 0.0–1.0
    var remainingMinutes: Int? = nil

    private static let cardWidth: CGFloat  = 115
    private static let cardHeight: CGFloat = 165

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            cardVisual
                .frame(width: Self.cardWidth, height: Self.cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                        .strokeBorder(
                            isFocused ? AppTheme.Colors.primary : .clear,
                            lineWidth: 2.5
                        )
                }
                .overlay(alignment: .topLeading) {
                    if isNew { newBadge }
                }
                .overlay(alignment: .topTrailing) {
                    if let rating = item.rating { ratingBadge(rating) }
                }
                .overlay {
                    if isFocused { playOverlay }
                }

            cardFooter
                .frame(width: Self.cardWidth, alignment: .leading)
        }
    }

    // MARK: - Card visual

    private var cardVisual: some View {
        ZStack {
            if let data = item.image, let img = Image(data: data) {
                img
                    .resizable()
                    .scaledToFill()
            } else {
                gradientFallback
            }

            if isFocused {
                Color.black.opacity(0.35)
            }
        }
    }

    private var gradientFallback: LinearGradient {
        let palettes: [[Color]] = [
            [Color(red: 0.27, green: 0.08, blue: 0.50), Color(red: 0.47, green: 0.16, blue: 0.70)],
            [Color(red: 0.06, green: 0.18, blue: 0.35), Color(red: 0.10, green: 0.35, blue: 0.50)],
            [Color(red: 0.05, green: 0.28, blue: 0.22), Color(red: 0.10, green: 0.42, blue: 0.36)],
            [Color(red: 0.25, green: 0.10, blue: 0.40), Color(red: 0.42, green: 0.22, blue: 0.60)],
            [Color(red: 0.35, green: 0.12, blue: 0.08), Color(red: 0.55, green: 0.25, blue: 0.12)],
        ]
        let index = abs(item.id.hashValue) % palettes.count
        return LinearGradient(
            colors: palettes[index],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Overlays

    private var playOverlay: some View {
        Image(systemName: "play.fill")
            .font(.system(size: 22))
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(.black.opacity(0.50))
            .clipShape(Circle())
    }

    private var newBadge: some View {
        Text("NOUVEAU")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(.white)
            .kerning(0.5)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(AppTheme.Colors.badgeNew)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.badge))
            .padding(8)
    }

    private func ratingBadge(_ rating: Double) -> some View {
        Text(String(format: "★ %.1f", rating))
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(.black.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.badge))
            .padding(8)
    }

    // MARK: - Footer

    private var cardFooter: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(item.seriesName ?? item.title)
                .font(AppTheme.Typography.strong)
                .foregroundStyle(isFocused ? AppTheme.Colors.primary : .white)
                .lineLimit(1)

            if let percent = progressPercent, let minutes = remainingMinutes {
                Text("\(Int(percent * 100))% · \(minutes)min restantes")
                    .font(AppTheme.Typography.tiny)
                    .foregroundStyle(AppTheme.Colors.primary)
                    .lineLimit(1)
            } else if let genre = item.genres?.first {
                Text(genre)
                    .font(AppTheme.Typography.tiny)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
            }
        }
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
