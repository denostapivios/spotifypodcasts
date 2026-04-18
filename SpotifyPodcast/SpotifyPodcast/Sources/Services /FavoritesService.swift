//
//  FavoritesService.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 18.04.2026.
//

import Foundation
import SwiftData

final class FavoritesService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func add(_ episode: PodcastEpisode) throws {
        let favorite = FavoritePodcast(from: episode)
        modelContext.insert(favorite)
        try modelContext.save()
    }

    func remove(id: String) throws {
        let descriptor = FetchDescriptor<FavoritePodcast>(
            predicate: #Predicate { $0.id == id }
        )
        let results = try modelContext.fetch(descriptor)
        results.forEach { modelContext.delete($0) }
        try modelContext.save()
    }

    func isFavorite(id: String) -> Bool {
        let descriptor = FetchDescriptor<FavoritePodcast>(
            predicate: #Predicate { $0.id == id }
        )
        return (try? modelContext.fetchCount(descriptor)) ?? 0 > 0
    }

    func fetchAll() throws -> [PodcastEpisode] {
        let descriptor = FetchDescriptor<FavoritePodcast>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { $0.toPodcastEpisode() }
    }
}
