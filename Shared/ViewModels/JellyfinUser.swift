//
//  JellyfinUser.swift
//  xstream-player
//
//  Created by Jordan Sinou on 27/04/2026.
//

struct JellyfinUser: Decodable {
    let id: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}
