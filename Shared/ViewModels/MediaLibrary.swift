//
//  MediaLibrary.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//

import SwiftUI

@Observable
final class MediaLibrary {
    var items: [MediaItem] = []
    var isLoading: Bool = false
    var error: APIError? = nil
    
    func loadItems(userId: String) async {
        isLoading = true
        error = nil
        
        do {
            items = try await APIClient.shared.fetchItems(userId: userId)
        } catch let e as APIError {
            error = e
        } catch {
            print("Error: \(error)")
        }
        
        isLoading = false
    }
}
