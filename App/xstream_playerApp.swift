//
//  xstream_playerApp.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI
import SwiftData

@main
struct xstream_playerApp: App {
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
