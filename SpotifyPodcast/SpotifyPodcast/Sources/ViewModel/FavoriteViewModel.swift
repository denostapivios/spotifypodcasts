//
//  FavoriteViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 18.04.2026.
//

import Foundation
import SwiftData

@Observable
@MainActor
final class FavoriteViewModel {
    private(set) var favorites: [PodcastEpisode] = []
    private let service: FavoritesService

    init(modelContext: ModelContext) {
        self.service = FavoritesService(modelContext: modelContext)
        loadFavorites()
    }

    func toggleFavorite(_ episode: PodcastEpisode) {
        if isFavorite(episode) {
            try? service.remove(id: episode.id)
        } else {
            try? service.add(episode)
        }
        loadFavorites()
    }

    func isFavorite(_ episode: PodcastEpisode) -> Bool {
        favorites.contains { $0.id == episode.id }
    }

    func loadFavorites() {
        favorites = (try? service.fetchAll()) ?? []
    }
}
