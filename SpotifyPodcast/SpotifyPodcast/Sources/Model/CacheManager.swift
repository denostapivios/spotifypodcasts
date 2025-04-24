//
//  CacheManager.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 25.03.2025.
//

import Foundation

class CacheManager {
    private let cacheKey = "cachedPodcasts"
    init() {}
    
    // Loading cached data
    func loadCachedData() async throws -> PodcastResponse? {
        guard let cachedData = UserDefaults.standard.data(forKey: cacheKey) else { return nil }
        return try JSONDecoder().decode(PodcastResponse.self, from: cachedData)
    }
    
    // Caching data
    func saveToCache(data: PodcastResponse) async throws {
        let encodedData = try JSONEncoder().encode(data)
        UserDefaults.standard.set(encodedData, forKey: cacheKey)
    }
}



