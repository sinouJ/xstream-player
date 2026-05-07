import SwiftUI

struct HomeTabView: View {
    let username: String
    var libraries: [MediaItem]
    @Environment(MediaLibrary.self) private var library
    @State private var selectedItem: MediaItem? = nil

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Accueil", username: username)
            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {

                    if let featured = library.items.first {
                        HeroCard(item: featured, onTap: { selectedItem = featured })
                            .padding(.horizontal, AppTheme.Spacing.sm)
                            .task {
                                await library.loadImageItem(itemId: featured.id)
                            }
                    }

                    if !library.resumables.isEmpty {
                        resumeSection
                    }

                    if !library.lastFilms.isEmpty {
                        lastFilmsSection
                    }
                    
                    if !library.lastSeries.isEmpty {
                        lastSeriesSection
                    }

                }
                .padding(.top, AppTheme.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        #if os(macOS)
        .sheet(item: $selectedItem) { item in
            MediaDetailView(item: item, isLoading: library.isLoading)
                .task {
                    await library.loadImageForMediaDetailView(itemId: item.id)
                }
                .frame(minWidth: 700, minHeight: 500)
        }
        #else
        .fullScreenCover(item: $selectedItem) { item in
            MediaDetailView(item: item, isLoading: library.isLoading)
                .task {
                   await library.loadImageForMediaDetailView(itemId: item.id)
                }
        }
        #endif
        .task {
            let userId = AuthService.shared.userId ?? ""
            await library.loadIfNeeded(userId: userId)
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
                            onTap: { selectedItem = item }
                        )
                        .task {
                            await library.loadImageForResumable(itemId: item.id)
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
                            onTap: { selectedItem = item }
                        )
                        .task {
                            await library.loadImageForLastFilm(itemId: item.id)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
            }
        }
    }
    
    // MARK: - Last series section

    private var lastSeriesSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            Text("Dernières séries ajoutés")
                .font(AppTheme.Typography.heading1)
                .foregroundStyle(.white)
                .padding(.horizontal, AppTheme.Spacing.sm)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(library.lastSeries) { item in
                        PosterCard(
                            item: item,
                            onTap: { selectedItem = item }
                        )
                        .task {
                            await library.loadImageForLastSeries(itemId: item.parentThumbItemId ?? item.id)
                        }
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.sm)
            }
        }
    }
}
