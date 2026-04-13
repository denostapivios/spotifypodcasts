//
//  BasePodcastViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import Foundation
import SwiftData

@MainActor
class BasePodcastViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    @Published var episodes: [PodcastEpisode] = []
    @Published var filteredEpisodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    @Published private(set) var canLoadMore = true

    let cacheManager: CacheManager
    let service: PodcastServiceProtocol
    let searchService: SearchService
    let limit = Constants.API.limit
    var offset = 0

    internal init(
        modelContext: ModelContext,
        service: any PodcastServiceProtocol = PodcastService(),
        searchService: SearchService = SearchService()
    ) {
        self.service = service
        self.cacheManager = CacheManager(modelContext: modelContext)
        self.searchService = searchService
    }

    // Override in subclasses to define sort order
    func sortEpisodes(_ episodes: [PodcastEpisode]) -> [PodcastEpisode] {
        episodes
    }

    func processResult(dataObject: PodcastResponse) -> [PodcastEpisode] {
        let items = dataObject.data?
            .podcastUnionV2?
            .episodesV2?
            .items ?? []
        return items.compactMap { PodcastEpisode(from: $0) }
    }

    func loadData() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true

        Task {
            defer { isLoading = false }
            await performLoad()
        }
    }

    func fetchPodcastsFromAPI() async {
        let initialOffset = offset

        do {
            let result = try await service.fetchData(
                from: Constants.API.baseURL,
                podcastID: Constants.API.podcastID,
                offset: offset,
                limit: limit
            )
            let fetched = processResult(dataObject: result)
            let unique = fetched.filter { new in
                !episodes.contains(where: { $0.id == new.id })
            }

            await MainActor.run {
                episodes.append(contentsOf: unique)
                episodes = sortEpisodes(episodes)
                applySearch()
                offset += limit
                canLoadMore = fetched.count == limit
            }

            if initialOffset == limit {
                try await cacheManager.saveToCache(data: result)
                print("Data loaded from API and cached.")
            }
        } catch {
            print("API error: \(error.localizedDescription)")

            if let fallback = service.loadFallbackFromFile() {
                let all = processResult(dataObject: fallback)
                let start = min(offset, all.count)
                let end = min(start + limit, all.count)
                let sliced = Array(all[start..<end])

                await MainActor.run {
                    episodes.append(contentsOf: sliced)
                    episodes = sortEpisodes(episodes)
                    applySearch()
                    offset += sliced.count
                    canLoadMore = sliced.count == limit
                    errorMessage = "Show fallback (offset \(start), limit \(limit))"
                }
                print("Loaded fallback.json (offset: \(start), limit: \(limit))")
            } else {
                await MainActor.run {
                    errorMessage = "Error: Failed to load API or fallback.json"
                }
                print("No fallback available")
            }
        }
    }

    func applySearch() {
        filteredEpisodes = searchService.filter(episodes, by: searchText)
    }

    func refreshData() {
        offset = 0
        canLoadMore = true
        episodes = []
        loadData()
    }
}

private extension BasePodcastViewModel {
    func performLoad() async {
        do {
            if offset == 0,
               let cachedData = try await cacheManager.loadCachedData() {
                try await handleInitialLoadWithCache(cachedData: cachedData)
            } else {
                print("No cache available or this is not the first load — fetchPodcastsFromAPI()")
                await fetchPodcastsFromAPI()
            }
        } catch {
            print("Error loading from cache: \(error.localizedDescription)")
            await fetchPodcastsFromAPI()
        }
    }

    func handleInitialLoadWithCache(cachedData: PodcastResponse) async throws {
        let apiResponse = try await service.fetchData(
            from: Constants.API.baseURL,
            podcastID: Constants.API.podcastID,
            offset: offset,
            limit: limit
        )
        let cachedEpisodes = extractEpisodes(from: cachedData)
        let apiEpisodes = extractEpisodes(from: apiResponse)

        if cachedEpisodes == apiEpisodes {
            await MainActor.run {
                updateUI(with: cachedEpisodes)
            }
            print("Using cache — data hasn't changed")
        } else {
            await MainActor.run {
                applyEpisodes(from: apiResponse)
            }
            try await cacheManager.saveToCache(data: apiResponse)
            print("Cache updated with new data from API")
        }
    }

    func extractEpisodes(from response: PodcastResponse) -> [PodcastEpisode] {
        response.data?
            .podcastUnionV2?
            .episodesV2?
            .items?
            .compactMap { PodcastEpisode(from: $0) } ?? []
    }

    func updateUI(with fetched: [PodcastEpisode]) {
        episodes = sortEpisodes(fetched)
        applySearch()
        offset = fetched.count
        canLoadMore = !fetched.isEmpty
    }

    func applyEpisodes(from data: PodcastResponse) {
        let newRows = processResult(dataObject: data)
        episodes = sortEpisodes(newRows)
        applySearch()
        offset = newRows.count
        canLoadMore = !newRows.isEmpty
    }
}
