//
//  CacheManager.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 25.03.2025.
//

import Foundation
import SwiftData

class CacheManager {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Loading cached data
    func loadCachedData() async throws -> PodcastResponse? {
        let results = try modelContext.fetch(FetchDescriptor<CachedPodcast>())
        guard let latest = results.first else { return nil }
        return try JSONDecoder().decode(PodcastResponse.self, from: latest.jsonData)
    }
    
    // Caching data
    func saveToCache(data: PodcastResponse) async throws {
        let encodedData = try JSONEncoder().encode(data)
        let existing = try modelContext.fetch(FetchDescriptor<CachedPodcast>())
        for item in existing {
            modelContext.delete(item)
        }
        
        let cached = CachedPodcast(jsonData: encodedData)
        modelContext.insert(cached)
        
        try modelContext.save()
    }
}



