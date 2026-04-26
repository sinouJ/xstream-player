//
//  Item.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import Foundation

struct MediaItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let url: URL
    let thumbnailURL: URL?
}
