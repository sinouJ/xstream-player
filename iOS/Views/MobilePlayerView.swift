//
//  MobilePlayerView.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI

// MARK: - Tab enum

enum AppTab: Hashable, Sendable {
    case home, library, downloads, search
}

// MARK: - Root view

struct MobilePlayerView: View {
    @State private var selectedTab: AppTab = .home
    @State private var folder = MediaFolder()

    private var username: String {
        AuthService.shared.credentials?.username ?? ""
    }

    var body: some View {
        Group {
            switch selectedTab {
            case .home: HomeTabView(username: username, libraries: folder.libraries)
                .task {
                    await folder.loadLibraries()
                }
            case .library:   LibraryTabView(username: username)
            case .downloads: DownloadsTabView(username: username)
            case .search:    SearchTabView(username: username)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            LiquidGlassTabBar(selection: $selectedTab)
        }
    }
}

private struct LibraryTabView: View {
    let username: String
    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Librairie", username: username)
            Spacer()
        }
    }
}

private struct DownloadsTabView: View {
    let username: String
    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Téléchargés", username: username)
            Spacer()
        }
    }
}

private struct SearchTabView: View {
    let username: String
    var body: some View {
        VStack(spacing: 0) {
            AppTopBar(title: "Recherche", username: username)
            Spacer()
        }
    }
}
