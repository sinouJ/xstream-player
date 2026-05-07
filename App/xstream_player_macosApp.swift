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
    @State private var mediaLibrary = MediaLibrary()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(mediaLibrary)
                .task {
                    await appState.bootstrap()
                }
        }
    }
}
