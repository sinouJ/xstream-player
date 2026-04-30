import SwiftUI

struct HomeTabView: View {
    let username: String
    var libraries: [MediaItem]
    @State private var library = MediaLibrary()

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Accueil", username: username)
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                    
                    if let featured = library.items.first {
                        HeroCard(item: featured)
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .task {
                                await library.loadImageItem(itemId: featured.id, imageType: .thumbnail)
                            }
                    }

                    if !library.resumables.isEmpty {
                        resumeSection
                    }
                    
                    if !library.lastFilms.isEmpty {
                        lastFilmsSection
                    }
                    
                }
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .task {
            let userId = AuthService.shared.userId ?? ""
            async let a: Void = library.loadItems(userId: userId)
            async let b: Void = library.loadResumableItems(userId: userId)
            async let c: Void = library.loadLastFilmItems(userId: userId)
            _ = await (a, b, c)
        }
    }

    // MARK: - Resume section

    private var resumeSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Reprendre la lecture")
                .font(AppTheme.Typography.heading1)
                .foregroundStyle(.white)
                .padding(.horizontal, AppTheme.Spacing.sm)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(library.resumables) { item in
                        PosterCard(
                            item: item,
                            progressPercent: item.watchedPercentage.map { $0 / 100 },
                            remainingMinutes: item.remainingMinutes
                        )
                        .task {
                            await library.loadImageForResumable(itemId: item.id, imageType: .primary)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
            }
        }
    }
    
    // MARK: - Last films section
    
    private var lastFilmsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Derniers films ajoutés")
                .font(AppTheme.Typography.heading1)
                .foregroundStyle(.white)
                .padding(.horizontal, AppTheme.Spacing.sm)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(library.lastFilms) { item in
                        PosterCard(
                            item: item,
                            progressPercent: item.watchedPercentage.map { $0 / 100 },
                            remainingMinutes: item.remainingMinutes
                        )
                        .task {
                            await library.loadImageForLastFilm(itemId: item.id, imageType: .primary)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
            }
        }
    }
}
