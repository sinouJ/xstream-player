//
//  MobilePlayerView.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import SwiftUI

struct MobilePlayerView: View {
    var mediaLibrary = MediaLibrary()
    
    var body: some View {
        Text("Mobile Player")

        ZStack {
            Color.black
            Text("hello world")
                .foregroundColor(.white)
        }
        .frame(width: 200, height: 100)
        
        List(mediaLibrary.items) { item in
            Text(item.title);
            Text(item.type);
        }
        .task {
            await mediaLibrary.loadItems(userId: "075aed76929e4b6abba76fcdaeae10ce")
        }
    }
}
