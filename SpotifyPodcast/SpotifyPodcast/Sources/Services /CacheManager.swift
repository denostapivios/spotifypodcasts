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
        let results = try await MainActor.run {
            try modelContext.fetch(FetchDescriptor<CachedPodcast>())
        }
        
        guard let latest = results.first else { return nil }
        
        return try await Task.detached(priority: .utility) {
            try JSONDecoder().decode(PodcastResponse.self, from: latest.jsonData)
        }.value
    }
    
    // Caching data
    func saveToCache(data: PodcastResponse) async throws {
        let encodedData = try await Task(priority: .utility) {
            try JSONEncoder().encode(data)
        }.value
        
        try await MainActor.run {
            let existing = try modelContext.fetch(FetchDescriptor<CachedPodcast>())
            
            if let current = existing.first, current.jsonData == encodedData {
                return
            }
            
            for item in existing {
                modelContext.delete(item)
            }
            
            let cached = CachedPodcast(jsonData: encodedData)
            modelContext.insert(cached)
            
            try modelContext.save()
        }
    }
}
