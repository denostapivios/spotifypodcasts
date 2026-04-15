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

    func isCacheExpired(ttl: TimeInterval = 86400) async -> Bool {
        let timestamp: Date? = await MainActor.run {
            try? modelContext.fetch(
                FetchDescriptor<CachedPodcast>(
                    sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
                )
            ).first?.timestamp
        }
        guard let timestamp else { return true }
        return Date().timeIntervalSince(timestamp) > ttl
    }

    func loadCachedData() async throws -> PodcastResponse? {
        let jsonData: Data? = try await MainActor.run {
            var descriptor = FetchDescriptor<CachedPodcast>(
                sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
            )
            descriptor.fetchLimit = 1
            return try modelContext.fetch(descriptor).first?.jsonData
        }

        guard let jsonData else { return nil }

        return try await Task.detached(priority: .utility) {
            try JSONDecoder().decode(PodcastResponse.self, from: jsonData)
        }.value
    }

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
