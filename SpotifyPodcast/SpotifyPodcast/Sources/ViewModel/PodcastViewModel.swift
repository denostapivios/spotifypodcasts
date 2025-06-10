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
    @Published var isPlayerPresented = false
    @Published var errorMessage: String?
    @Published var episodes: [PodcastEpisode] = []
    @Published var isLoading: Bool = false
    
    var player: AVPlayer?
    
    private let cacheManager: CacheManager
    private let service: PodcastServiceProtocol
    
    private let limit = Constants.API.limit
    private var offset = 0
    
    @Published private(set) var canLoadMore = true
    
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
        print("🔄 loadData() викликано — offset=\(offset), canLoadMore=\(canLoadMore), isLoading=\(isLoading)")
        guard !isLoading, canLoadMore else { return }
        isLoading = true
        
        Task {
            defer { isLoading = false
            }
            
            do {
                // First launch — comparing cache ↔ API
                if offset == 0 {
                    if let cachedData = try await cacheManager.loadCachedData() {
                        // Використовуємо кешовані дані до оновлення
                        await applyEpisodes(from: cachedData)
                        print("📥 Використано кеш перед оновленням")
                    }
                    let apiResponse = try await service.fetchData(
                        from: Constants.API.baseURL,
                        podcastID: Constants.API.podcastID,
                        offset: offset,
                        limit: limit
                    )
                    
                    try await cacheManager.saveToCache(data: apiResponse)
                    
                    if let updatedCachedData = try await cacheManager.loadCachedData() {
                        await applyEpisodes(from: updatedCachedData)
                        print("✅ Завантажено з кешу (або оновлено)")
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
                offset += limit
                canLoadMore = fetched.count == limit
            }
            
            if initialOffset == 0 {
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
    
    private func applyEpisodes(from data: PodcastResponse) async {
        let newRows = processResult(dataObject: data)
        episodes = newRows
        sortEpisodesByDate()
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
    
    func refreshData() {
        offset = 0
        canLoadMore = true
        episodes = []
        loadData()
    }
}
