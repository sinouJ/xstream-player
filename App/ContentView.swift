//
//  ContentView.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
