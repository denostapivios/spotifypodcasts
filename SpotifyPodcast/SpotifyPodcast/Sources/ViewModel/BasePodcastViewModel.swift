//
//  BasePodcastViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import Foundation
import SwiftData

@Observable
@MainActor
class BasePodcastViewModel {
    var searchText: String = ""
    var errorMessage: String?
    var episodes: [PodcastEpisode] = []
    var filteredEpisodes: [PodcastEpisode] = []
    var isLoading: Bool = false
    private(set) var canLoadMore = true

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

    func loadIfNeeded() async {
        guard !isLoading, episodes.isEmpty else { return }
        isLoading = true
        
        defer { isLoading = false }
        await performInitialLoad()
    }

    func forceRefresh() async {
        guard !isLoading else { return }
        reset()
        isLoading = true
        defer { isLoading = false }
        await fetchPodcastsFromAPI()
    }

    func loadData() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        Task {
            defer { isLoading = false }
            await fetchPodcastsFromAPI()
        }
    }

    func applySearch() {
        filteredEpisodes = searchService.filter(episodes, by: searchText)
    }
    
    func applySearchWithDebounce() async {
        do {
            try await Task.sleep(nanoseconds: 300_000_000)
            applySearch()
        } catch {
            
        }
    }
}


private extension BasePodcastViewModel {

    func reset() {
        offset = 0
        canLoadMore = true
        episodes = []
        filteredEpisodes = []
    }

    func performInitialLoad() async {
        do {
            let isExpired = await cacheManager.isCacheExpired()
            if !isExpired, let cachedData = try await cacheManager.loadCachedData() {
                let cachedEpisodes = extractEpisodes(from: cachedData)
                updateUI(with: cachedEpisodes)
                print("Cache is fresh — showing from cache, skipping API")
            } else {
                print("Cache expired or missing — fetching from API")
                await fetchPodcastsFromAPI()
            }
        } catch {
            print("Cache error: \(error.localizedDescription) — fetching from API")
            await fetchPodcastsFromAPI()
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

            episodes.append(contentsOf: unique)
            episodes = sortEpisodes(episodes)
            applySearch()
            offset += limit
            canLoadMore = fetched.count == limit

            if initialOffset == 0 {
                try await cacheManager.saveToCache(data: result)
                print("First page cached.")
            }
        } catch {
            print("API error: \(error.localizedDescription)")
            loadFallback()
        }
    }

    func loadFallback() {
        guard let fallback = service.loadFallbackFromFile() else {
            errorMessage = "Error: Failed to load API or fallback.json"
            print("No fallback available")
            return
        }

        let all = processResult(dataObject: fallback)
        let start = min(offset, all.count)
        let end = min(start + limit, all.count)
        let sliced = Array(all[start..<end])

        episodes.append(contentsOf: sliced)
        episodes = sortEpisodes(episodes)
        applySearch()
        offset += sliced.count
        canLoadMore = sliced.count == limit
        errorMessage = "Couldn't connect to the server. Showing cached data."
        print("Loaded fallback.json (offset: \(start), limit: \(limit))")
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
