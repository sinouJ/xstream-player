//
//  ErrorView.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        Text("Error")
    }
}
