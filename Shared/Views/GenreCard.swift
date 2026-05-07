import SwiftUI

struct GenreItem: Identifiable {
    var id: String { name }
    let name: String
    var image: Data?
    let representativeItemId: String
}

struct GenreCard: View {
    let genre: GenreItem
    var onTap: (() -> Void)? = nil

    @State private var isPressed = false

    private static let cardWidth: CGFloat = 155
    private static let cardHeight: CGFloat = 90

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            cardBackground
            labelOverlay
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card)
                .strokeBorder(
                    borderGradient,
                    lineWidth: isPressed ? 2 : 1
                )
                .opacity(isPressed ? 1 : 0.3)
        }
        .shadow(
            color: isPressed ? AppTheme.Colors.accent.opacity(0.5) : .clear,
            radius: 8,
            x: 0,
            y: 0
        )
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture { onTap?() }
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }

    // MARK: - Background

    private var cardBackground: some View {
        ZStack {
            if let data = genre.image, let img = Image(data: data) {
                img
                    .resizable()
                    .scaledToFill()
                    .frame(width: Self.cardWidth, height: Self.cardHeight)
                    .clipped()
            } else {
                gradientFallback
            }

            LinearGradient(
                colors: [.black.opacity(0.7), .black.opacity(0.15)],
                startPoint: .bottom,
                endPoint: .top
            )
        }
    }

    private var gradientFallback: some View {
        let palettes: [[Color]] = [
            [Color(red: 0.27, green: 0.08, blue: 0.50), Color(red: 0.47, green: 0.16, blue: 0.70)],
            [Color(red: 0.06, green: 0.18, blue: 0.35), Color(red: 0.10, green: 0.35, blue: 0.50)],
            [Color(red: 0.05, green: 0.28, blue: 0.22), Color(red: 0.10, green: 0.42, blue: 0.36)],
            [Color(red: 0.25, green: 0.10, blue: 0.40), Color(red: 0.42, green: 0.22, blue: 0.60)],
            [Color(red: 0.35, green: 0.12, blue: 0.08), Color(red: 0.55, green: 0.25, blue: 0.12)],
        ]
        let index = abs(genre.name.hashValue) % palettes.count
        return LinearGradient(
            colors: palettes[index],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Label

    private var labelOverlay: some View {
        Text(genre.name)
            .font(AppTheme.Typography.heading2)
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
            .padding(.horizontal, 12)
            .padding(.bottom, 10)
    }

    // MARK: - Border

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0.6),
                AppTheme.Colors.accent.opacity(0.4),
                .white.opacity(0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
