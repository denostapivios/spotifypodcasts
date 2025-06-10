//
//  CachedPodcast.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 29.05.2025.
//

import Foundation
import SwiftData

@Model
class CachedPodcast {
    var id: UUID
    var timestamp: Date
    var jsonData: Data
    
    init(id: UUID = .init(), timestamp: Date = .now, jsonData: Data) {
        self.id = id
        self.timestamp = timestamp
        self.jsonData = jsonData
    }
}
