//
//  xstream_player_tvosApp.swift
//  xstream.player.tvos
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI
import SwiftData

@main
struct xstream_player_tvosApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}
