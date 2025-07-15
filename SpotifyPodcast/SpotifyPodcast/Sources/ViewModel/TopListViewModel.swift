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
            await performLoad()
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
            print("Error loading from API: \(error.localizedDescription)")
            
            // fallback
            if let fallback = service.loadFallbackFromFile() {
                let fallbackEpisodes = processResult(dataObject: fallback)
                
                // offsetTop and limit
                let start = min(Constants.API.offsetTop, fallbackEpisodes.count)
                let end = min(start + Constants.API.limit, fallbackEpisodes.count)
                let sliced = Array(fallbackEpisodes[start..<end])
                await MainActor.run {
                    episodes = sliced
                    errorMessage = "Show fallback (offset \(start), limit \(Constants.API.limit))"
                }
                print("Loaded fallback.json")
            } else {
                await MainActor.run {
                    errorMessage = "Error loading data from API or fallback.json"
                }
                print("No fallback available")
            }
        }
    }
    
    func refreshData() {
        episodes = []
        loadData()
    }
}

private extension TopListViewModel {
    func performLoad() async {
        do {
            if let cachedData = try await cacheManager.loadCachedData() {
                try await handleInitialLoadWithCache(with: cachedData)
            } else {
                print("No cache available or this is not the first load — fetchPodcastsFromAPI()")
                await fetchPodcastsFromAPI()
            }
        } catch {
            print("Error loading from cache: \(error.localizedDescription)")
            await fetchPodcastsFromAPI()
        }
    }
    
    func handleInitialLoadWithCache(with cachedData: PodcastResponse) async throws {
        let apiResponse = try await service.fetchData(
            from: Constants.API.baseURL,
            podcastID: Constants.API.podcastID,
            offset: Constants.API.offsetTop,
            limit: Constants.API.limit
        )
        
        let cachedEpisodes = extractEpisodes(from: cachedData)
        let apiEpisodes = extractEpisodes(from: apiResponse)
        
        if cachedEpisodes == apiEpisodes {
            await MainActor.run {
                episodes = cachedEpisodes
            }
            print("Using cache — data hasn't changed")
        } else {
            await MainActor.run {
                episodes = apiEpisodes
            }
            try await cacheManager.saveToCache(data: apiResponse)
            print("Cache updated with new data from API")
        }
    }
    
    func extractEpisodes(from response: PodcastResponse) -> [PodcastEpisode] {
        let items = response.data?
            .podcastUnionV2?
            .episodesV2?
            .items ?? []
        return items.compactMap { PodcastEpisode(from: $0) }
    }
    
}
