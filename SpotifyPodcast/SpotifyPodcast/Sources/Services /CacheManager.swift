//
//  CacheManager.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 25.03.2025.
//

import Foundation
import SwiftData
import CryptoKit


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
        let encodedData = try JSONEncoder().encode(data)
        let newHash = await hashPodcastData(data)
        
        try await MainActor.run {
            let existing = try modelContext.fetch(FetchDescriptor<CachedPodcast>())
            
            if let existingItem = existing.first {
                if existingItem.contentHash == newHash {
                    print("Cache has not changed - entry skipped")
                    return
                }
                modelContext.delete(existingItem)
            }
            
            let cached = CachedPodcast(
                timestamp: .now,
                jsonData: encodedData,
                contentHash: newHash,
            )
            modelContext.insert(cached)
            print("New data saved to cache")
            
        }
    }
    
    private func hashPodcastData(_ data: PodcastResponse) async -> String {
        await Task(priority: .utility) {
            guard let encoded = try? JSONEncoder().encode(data) else { return "" }
            let digest = SHA256.hash(data: encoded)
            return digest.map { String(format: "%02x", $0) }.joined()
        }.value
    }
}
