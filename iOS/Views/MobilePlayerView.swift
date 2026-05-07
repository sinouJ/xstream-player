import SwiftUI

enum AppTab: Hashable, Sendable {
    case home, library, downloads, search
}

struct MobilePlayerView: View {
    @State private var selectedTab: AppTab = .home
    @State private var searchText = ""
    @State private var isSearchActive = false

    private var username: String {
        AuthService.shared.credentials?.username ?? ""
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Accueil", systemImage: "house.fill", value: AppTab.home) {
                HomeTabView(username: username)
            }

            Tab("Librairie", systemImage: "square.grid.2x2.fill", value: AppTab.library) {
                LibraryTabView(username: username)
            }

            Tab("Téléchargés", systemImage: "arrow.down.circle.fill", value: AppTab.downloads) {
                DownloadsTabView(username: username)
            }

            Tab(value: AppTab.search, role: .search) {
                NavigationStack {
                    SearchTabView(searchText: searchText)
                        .navigationTitle("Recherche")
                        .navigationBarTitleDisplayMode(.large)
                        .searchable(
                            text: $searchText,
                            isPresented: $isSearchActive,
                            prompt: "Rechercher..."
                        )
                        .toolbarBackground(AppTheme.Colors.background, for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarColorScheme(.dark, for: .navigationBar)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .tint(AppTheme.Colors.accent)
        .toolbarBackground(AppTheme.Colors.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .onChange(of: selectedTab) { _, newTab in
            isSearchActive = (newTab == .search)
        }
    }
}

// MARK: - Tab content views

private struct LibraryTabView: View {
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Librairie", username: username)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

private struct DownloadsTabView: View {
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Téléchargés", username: username)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}

private struct SearchTabView: View {
    let searchText: String

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.Colors.background.ignoresSafeArea())
    }
}
