//
//  TopListViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 21.05.2025.
//

import Foundation
import SwiftData

@Observable
@MainActor
class TopListViewModel {
    var errorMessage: String?
    var episodes: [PodcastEpisode] = []
    var isLoading: Bool = false

    private let cacheManager: CacheManager
    private let service: PodcastServiceProtocol

    internal init(modelContext: ModelContext, service: any PodcastServiceProtocol = PodcastService()) {
        self.service = service
        self.cacheManager = CacheManager(modelContext: modelContext)
    }

    // MARK: - Public API

    /// Завантажує тільки якщо дані ще не завантажені
    func loadIfNeeded() async {
        guard !isLoading, episodes.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        await performLoad()
    }

    /// Pull-to-refresh — завжди йде в API
    func forceRefresh() async {
        guard !isLoading else { return }
        episodes = []
        isLoading = true
        defer { isLoading = false }
        await fetchFromAPI()
    }
}

// MARK: - Private

private extension TopListViewModel {

    func performLoad() async {
        await fetchFromAPI()
    }

    func fetchFromAPI() async {
        do {
            let result = try await service.fetchData(
                from: Constants.API.baseURL,
                podcastID: Constants.API.podcastID,
                offset: Constants.API.offsetTop,
                limit: Constants.API.limit
            )
            episodes = extractEpisodes(from: result)
            print("TopList: loaded from API")
        } catch {
            print("TopList API error: \(error.localizedDescription)")
            loadFallback()
        }
    }

    func loadFallback() {
        guard let fallback = service.loadFallbackFromFile() else {
            errorMessage = "Error loading data from API or fallback.json"
            print("TopList: no fallback available")
            return
        }
        // fallback.json містить всі епізоди — беремо потрібний зріз
        let all = extractEpisodes(from: fallback)
        let start = min(Constants.API.offsetTop, all.count)
        let end = min(start + Constants.API.limit, all.count)
        episodes = Array(all[start..<end])
        print("TopList: loaded from fallback.json")
    }

    func extractEpisodes(from response: PodcastResponse) -> [PodcastEpisode] {
        let items = response.data?
            .podcastUnionV2?
            .episodesV2?
            .items ?? []
        return items.compactMap { PodcastEpisode(from: $0) }
    }
}
