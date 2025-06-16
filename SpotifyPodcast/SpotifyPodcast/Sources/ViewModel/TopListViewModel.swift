//
//  TopListViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 21.05.2025.
//

import Foundation
import SwiftData

@MainActor
class TopListViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var episodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    
    private let cacheManager: CacheManager
    private let service: PodcastServiceProtocol
    
    internal init(modelContext: ModelContext, service: any PodcastServiceProtocol = PodcastService()) {
        self.service = service
        self.cacheManager = CacheManager(modelContext: modelContext)
    }
    
    func processResult(dataObject:PodcastResponse) -> [PodcastEpisode] {
        let items = dataObject.data?
            .podcastUnionV2?
            .episodesV2?
            .items ?? []
        return items.compactMap { PodcastEpisode(from: $0) }
    }
    
    func loadData() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            defer {
                Task { @MainActor in
                    isLoading = false
                }
            }
            
            do {
                // First launch — comparing cache ↔ API
                if let cachedData = try await cacheManager.loadCachedData() {
                    let apiResponse = try await service.fetchData(
                        from: Constants.API.baseURL,
                        podcastID: Constants.API.podcastID,
                        offset: Constants.API.offsetTop,
                        limit: Constants.API.limit
                    )
                    
                    // Get arrays of raw items
                    let cachedItems = cachedData.data?
                        .podcastUnionV2?
                        .episodesV2?
                        .items ?? []
                    let apiItems = apiResponse.data?
                        .podcastUnionV2?
                        .episodesV2?
                        .items ?? []
                    
                    // Сomparing eposodes
                    let cachedEpisodes = cachedItems.compactMap { PodcastEpisode(from: $0) }
                    let apiEpisodes = apiItems.compactMap { PodcastEpisode(from: $0) }
                    
                    if cachedEpisodes == apiEpisodes {
                        
                        // Cache and API match — using data from cache
                        await MainActor.run {
                            episodes = cachedEpisodes
                        }
                        print("Using cache — data hasn't changed")
                    } else {
                        
                        // Cache is outdated — fetching from API and updating the cache
                        await MainActor.run {
                            episodes = apiEpisodes
                        }
                        try await cacheManager.saveToCache(data: apiResponse)
                        print("Cache updated with new data from API")
                    }
                } else {
                    
                    // When offset ≠ 0 or cache is missing — regular pagination via API
                    print("No cache available or this is not the first load — fetchPodcastsFromAPI()")
                    await fetchPodcastsFromAPI()
                }
            } catch {
                print("Error loading from cache: \(error.localizedDescription)")
                await fetchPodcastsFromAPI()
            }
        }
    }
    
    // Loading data from the API
    func fetchPodcastsFromAPI() async {
        do {
            let result = try await service.fetchData(
                from: Constants.API.baseURL,
                podcastID: Constants.API.podcastID,
                offset: Constants.API.offset,
                limit: Constants.API.limit
            )
            let fetched = processResult(dataObject: result)
            
            await MainActor.run {
                episodes = fetched
            }
            
            try await cacheManager.saveToCache(data: result)
            print("Data loaded from API and cached.")
            
        } catch {
            await MainActor.run {
                errorMessage = "Error loading data from API: \(error.localizedDescription)"
            }
            print("Error loading from API: \(error.localizedDescription)")
        }
    }
    
    func refreshData() {
        episodes = []
        loadData()
    }
}
