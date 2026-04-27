//
//  Item.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import Foundation

struct JellyfinItemsResponse: Decodable {
    let items: [JellyfinItem]
    enum CodingKeys: String, CodingKey {
        case items = "Items"
    }
}

struct JellyfinItem: Decodable {
    let id: String
    let name: String
    let type: String
    let productionYear: Int?
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case type = "Type"
        case productionYear = "ProductionYear"
    }
}

struct MediaItem: Identifiable {
    let id: String
    let title: String
    let type: String
    let year: Int?

    init(from item: JellyfinItem) {
        self.id    = item.id
        self.title = item.name
        self.type  = item.type
        self.year  = item.productionYear
    }
}
