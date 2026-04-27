//
//  ContentView.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI
import SwiftData


struct ContentView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            switch appState.phase {
            case .launching:
                SplashView()
            case .needsAuth:
                LoginView()
            case .ready:
                MainView()
            case .error(let message):
                ErrorView(message: message) {
                    appState.retry()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.phase)
    }
}

struct MainView: View {
    var body: some View {
        #if os(tvOS)
        TVPlayerView()
        #elseif os(macOS)
        DesktopPlayerView()
        #else
        MobilePlayerView()
        #endif
    }
}

#Preview {
    ContentView()
}
