//
//  Item.swift
//  xstream-player
//
//  Created by Jordan Sinou on 25/04/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
