import SwiftUI

struct MediaDetailView: View {
    let item: MediaItem

    @State private var backdropData: Data? = nil
    @State private var isSynopsisExpanded = false
    @State private var isFavorite = false
    @Environment(\.dismiss) private var dismiss

    private static let heroHeight: CGFloat = 340

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                heroSection

                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    titleSection
                    badgesRow
                    actionButtons

                    Rectangle()
                        .fill(AppTheme.Colors.border.opacity(0.5))
                        .frame(height: 1)

                    descriptionSection
                    synopsisSection
                    castSection
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.top, AppTheme.Spacing.sm)

                watchButton
                    .padding(.horizontal, AppTheme.Spacing.sm)
                    .padding(.vertical, AppTheme.Spacing.md)
            }
        }
        .background(AppTheme.Colors.background)
        .ignoresSafeArea(edges: .top)
        .task {
            if let data = try? await APIClient.shared.fetchImageItem(imageType: .banner, itemId: item.id) {
                backdropData = data
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack {
            heroBackground

            LinearGradient(
                colors: [.clear, AppTheme.Colors.background],
                startPoint: .init(x: 0.5, y: 0.45),
                endPoint: .bottom
            )

            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 38, height: 38)
                            .background(.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button { isFavorite.toggle() } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(isFavorite ? AppTheme.Colors.danger : .white)
                            .frame(width: 38, height: 38)
                            .background(.black.opacity(0.45))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
                .padding(.top, 56)
                Spacer()
            }

            Button {} label: {
                Image(systemName: "play.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(.white)
                    .frame(width: 66, height: 66)
                    .background(.white.opacity(0.15))
                    .clipShape(Circle())
                    .overlay {
                        Circle().strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                    }
            }
            .buttonStyle(.plain)

            if let rating = item.rating {
                HStack {
                    Spacer()
                    ratingBadge(rating)
                        .padding(.trailing, AppTheme.Spacing.sm)
                }
            }
        }
        .frame(height: Self.heroHeight)
        .clipped()
    }

    @ViewBuilder
    private var heroBackground: some View {
        if let data = backdropData ?? item.image, let img = Image(data: data) {
            img.resizable().scaledToFill()
        } else {
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.18, blue: 0.35),
                    Color(red: 0.12, green: 0.08, blue: 0.28)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func ratingBadge(_ rating: Double) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(AppTheme.Colors.accent)
                if let votes = item.voteCount {
                    Text(votes >= 1000
                         ? String(format: "%.1fk", Double(votes) / 1000)
                         : "\(votes)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            Text(String(format: "%.1f/10", rating))
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.Colors.surface.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
    }

    // MARK: - Title

    private var titleSection: some View {
        let displayTitle = (item.seriesName ?? item.title)
            + (item.year.map { " (\($0))" } ?? "")
        return Text(displayTitle)
            .font(.system(size: 22, weight: .bold))
            .foregroundStyle(.white)
    }

    // MARK: - Badges

    private var badgesRow: some View {
        HStack(spacing: 8) {
            if let age = item.officialRating { pill(age) }
            pill("4K")
            if let r = item.rating {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(AppTheme.Colors.accent)
                    Text(String(format: "%.1f", r))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.Colors.accent.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.badge))
            }
        }
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.Colors.badgeNeutral)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.badge))
    }

    // MARK: - Action buttons

    private var actionButtons: some View {
        HStack(spacing: 10) {
            actionButton(icon: "plus", label: "Ma liste") {}
            actionButton(icon: "arrow.down.to.line", label: "Télécharger") {}
            actionButton(icon: "square.and.arrow.up", label: "Partager") {}
        }
    }

    private func actionButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                Text(label)
                    .font(AppTheme.Typography.tiny)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.Colors.surfaceGlass)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Description

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Description")
                .font(AppTheme.Typography.heading1)
                .foregroundStyle(.white)

            let parts = [
                item.genres?.joined(separator: ", "),
                item.runtimeMinutes.map { "\($0 / 60)h \($0 % 60)min" }
            ].compactMap { $0 }

            if !parts.isEmpty {
                Text(parts.joined(separator: " • "))
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    // MARK: - Synopsis

    private var synopsisSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("Synopsis")
                    .font(AppTheme.Typography.heading1)
                    .foregroundStyle(.white)
                Spacer()
                if let date = item.premiereDate {
                    Text(formattedDate(date))
                        .font(AppTheme.Typography.tiny)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }

            if let overview = item.overview {
                Text(overview)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(isSynopsisExpanded ? nil : 3)

                if !isSynopsisExpanded {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSynopsisExpanded = true
                        }
                    } label: {
                        Text("Lire la suite →")
                            .font(AppTheme.Typography.strong)
                            .foregroundStyle(AppTheme.Colors.primary)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text("Aucune description disponible.")
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "EEE d MMM yyyy"
        let s = f.string(from: date)
        return s.prefix(1).uppercased() + s.dropFirst()
    }

    // MARK: - Cast

    private var castSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Casting")
                .font(AppTheme.Typography.heading1)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Self.mockCast) { member in
                        VStack(spacing: 6) {
                            Text(member.initials)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 58, height: 58)
                                .background(member.color)
                                .clipShape(Circle())
                            Text(member.name)
                                .font(AppTheme.Typography.strong)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            Text(member.role)
                                .font(AppTheme.Typography.tiny)
                                .foregroundStyle(.white.opacity(0.55))
                                .lineLimit(1)
                        }
                        .frame(width: 72)
                    }
                }
            }
        }
    }

    // MARK: - Watch button

    private var watchButton: some View {
        Button {} label: {
            Label("Regarder maintenant", systemImage: "play.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [AppTheme.Colors.gradientStart, AppTheme.Colors.gradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.pill))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Mock cast (TODO: remplacer par Fields=People depuis l'API)

    private struct CastMember: Identifiable {
        let id = UUID()
        let initials: String
        let name: String
        let role: String
        let color: Color
    }

    private static let mockCast: [CastMember] = [
        CastMember(initials: "RS", name: "Réa",  role: "Commandante",  color: Color(red: 0.35, green: 0.20, blue: 0.70)),
        CastMember(initials: "KD", name: "Kael", role: "Ingénieur",    color: Color(red: 0.10, green: 0.42, blue: 0.36)),
        CastMember(initials: "MV", name: "Mira", role: "Scientifique", color: Color(red: 0.62, green: 0.36, blue: 0.12)),
        CastMember(initials: "OP", name: "Orin", role: "Pilote",       color: Color(red: 0.52, green: 0.13, blue: 0.28)),
    ]
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
