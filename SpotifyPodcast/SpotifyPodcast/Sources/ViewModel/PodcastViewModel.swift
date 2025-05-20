//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Foundation
import AVKit

@MainActor
class PodcastViewModel: ObservableObject {
    @Published var isPlayerPresented = false
    @Published var errorMessage: String?
    @Published var episodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    
    var player: AVPlayer?
    
    private let cacheManager = CacheManager()
    private let service: PodcastServiceProtocol
    private let cacheKey = "cachedPodcasts"
    
    private var offset = 0
    private let limit = 6
    @Published private(set) var canLoadMore = true
    
    internal init(service: any PodcastServiceProtocol = PodcastService()) {
        self.service = service
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
            defer { isLoading = false
            }
            
            do {
                if offset == 0,
                   let cachedData = try await cacheManager.loadCachedData() {
                    let newRows = processResult(dataObject: cachedData)
                    
                    await MainActor.run {
                        episodes = newRows
                        offset = newRows.count
                        canLoadMore = !newRows.isEmpty
                    }
                    print("Data loaded from cache")
                } else {
                    print("No cached data available, loading from API")
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
        let initialOffset = offset
        
        do {
            let result = try await service.fetchData(offset: offset, limit: limit)
            let fetched = processResult(dataObject: result)
            
            let unique = fetched.filter { newEpisod in
                !episodes.contains(where: { $0.id == newEpisod.id })
            }
            
            await MainActor.run {
                episodes.append(contentsOf: unique)
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
    
    func refreshData() {
        offset = 0
        canLoadMore = true
        episodes = []
        loadData()
    }
}
