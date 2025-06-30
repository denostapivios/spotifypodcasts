//
//  PopularViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 02.06.2025.
//

import Foundation
import SwiftData

@MainActor
final class PopularViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    @Published var episodes: [PodcastEpisode] = []
    @Published var filteredEpisodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    @Published private(set) var canLoadMore = true
    
    private let cacheManager: CacheManager
    private let service: PodcastServiceProtocol
    private let searchService: SearchService
    private let limit = Constants.API.limit
    private var offset = 0
    
    init(
        modelContext: ModelContext,
        service: any PodcastServiceProtocol = PodcastService(),
        searchService: SearchService = SearchService()
    ) {
        self.service = service
        self.cacheManager = CacheManager(modelContext: modelContext)
        self.searchService = searchService
    }
    
    func processResult(dataObject:PodcastResponse) -> [PodcastEpisode] {
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
            
            let unique = fetched.filter { newEpisod in
                !episodes.contains(where: { $0.id == newEpisod.id })
            }
            
            await MainActor.run {
                episodes.append(contentsOf: unique)
                sortEpisodesByDuration()
                applySearch()
                offset += limit
                canLoadMore = fetched.count == limit
            }
            
            if initialOffset == limit {
                try await cacheManager.saveToCache(data: result)
                print("Data loaded from API and cached.")
            }
        } catch {
            await MainActor.run {
                errorMessage = "Error loading data from API: \(error.localizedDescription)"
            }
            print("Error loading from API: \(error.localizedDescription)")
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

private extension PopularViewModel {
    func performLoad() async {
        do {
            if isFirstPageLoad(),
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
    
    func isFirstPageLoad() -> Bool {
        offset == 0
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
    
    func updateUI(with episodes: [PodcastEpisode]) {
        self.episodes = episodes
        sortEpisodesByDuration()
        applySearch()
        offset = episodes.count
        canLoadMore = !episodes.isEmpty
    }
    
    func applyEpisodes(from data: PodcastResponse) {
        let newRows = processResult(dataObject: data)
        episodes = newRows
        sortEpisodesByDuration()
        applySearch()
        offset = newRows.count
        canLoadMore = !newRows.isEmpty
    }
    
    func sortEpisodesByDuration() {
        episodes.sort { $0.durationMilliseconds > $1.durationMilliseconds }
    }
}
