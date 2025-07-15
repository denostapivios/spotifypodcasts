//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Foundation
import AVKit
import SwiftData

@MainActor
class PodcastViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var isPlayerPresented = false
    @Published var errorMessage: String?
    @Published var episodes: [PodcastEpisode] = []
    @Published var filteredEpisodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    
    var player: AVPlayer?
    
    private let cacheManager: CacheManager
    private let service: PodcastServiceProtocol
    private let searchService: SearchService
    private let limit = Constants.API.limit
    private var offset = 0
    
    @Published private(set) var canLoadMore = true
    
    internal init(
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
    
    // audio
    func playAudio(from urlString: String) {
        guard let url = URL(string: urlString), urlString != "-" else {
            print("Invalid audio URL")
            return
        }
        player = AVPlayer(url: url)
        player?.play()
        isPlayerPresented = true
    }
    
    deinit {
        player?.pause()
        player = nil
    }
    
    func loadData() {
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        
        Task {
            defer { isLoading = false }
            await performLoad()
        }
    }
    
    // Loading data from the API
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
                sortEpisodesByDate()
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
                let allEpisodes = processResult(dataObject: fallback)
                let start = min(offset, allEpisodes.count)
                let end = min(start + limit, allEpisodes.count)
                let sliced = Array(allEpisodes[start..<end])
                
                await MainActor.run {
                    episodes.append(contentsOf: sliced)
                    sortEpisodesByDate()
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

private extension PodcastViewModel {
    private func performLoad() async {
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
    
    private func isFirstPageLoad() -> Bool {
        offset == 0
    }
    
    private func handleInitialLoadWithCache(cachedData: PodcastResponse) async throws {
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
    
    private func extractEpisodes(from response: PodcastResponse) -> [PodcastEpisode] {
        response.data?
            .podcastUnionV2?
            .episodesV2?
            .items?
            .compactMap { PodcastEpisode(from: $0) } ?? []
    }
    
    private func updateUI(with episodes: [PodcastEpisode]) {
        self.episodes = episodes
        sortEpisodesByDate()
        applySearch()
        offset = episodes.count
        canLoadMore = !episodes.isEmpty
    }
    
    private func applyEpisodes(from data: PodcastResponse) {
        let newRows = processResult(dataObject: data)
        episodes = newRows
        sortEpisodesByDate()
        applySearch()
        offset = newRows.count
        canLoadMore = !newRows.isEmpty
    }
    
    private func sortEpisodesByDate() {
        episodes.sort {
            guard let date1 = DateFormatter.mediumDate.date(from: $0.releaseDate),
                  let date2 = DateFormatter.mediumDate.date(from: $1.releaseDate) else {
                return false
            }
            return date1 > date2
        }
    }
}
