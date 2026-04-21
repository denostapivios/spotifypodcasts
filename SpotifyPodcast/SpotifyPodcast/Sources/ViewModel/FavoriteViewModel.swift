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
    var errorMessage: String?
    private let service: FavoritesService

    init(modelContext: ModelContext) {
        self.service = FavoritesService(modelContext: modelContext)
        loadFavorites()
    }

    func toggleFavorite(_ episode: PodcastEpisode) {
        do {
            if isFavorite(episode) {
                try service.remove(id: episode.id)
            } else {
                try service.add(episode)
            }
            loadFavorites()
        } catch {
            errorMessage = "Failed to update favorites. Please try again."
            print("FavoriteViewModel error: \(error.localizedDescription)")
        }
    }

    func isFavorite(_ episode: PodcastEpisode) -> Bool {
        favorites.contains { $0.id == episode.id }
    }

    func loadFavorites() {
        do {
            favorites = try service.fetchAll()
        } catch {
            errorMessage = "Failed to load favorites. Please try again."
            print("FavoriteViewModel load error: \(error.localizedDescription)")
        }
    }
}
