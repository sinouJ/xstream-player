//
//  xstream_player_macosApp.swift
//  xstream.player.macos
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI
import SwiftData

@main
struct xstream_player_macosApp: App {
    @State private var appState = AppState()
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    await appState.bootstrap()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
