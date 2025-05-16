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
        refreshData()
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
            print("Невірний URL для аудіо")
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
        
        print("▶️ loadData start — offset:", offset,
              "episodes:", episodes.count,
              "canLoadMore:", canLoadMore)
        
        Task {
            defer { isLoading = false
                print("⏹ loadData end — offset:", offset,
                      "episodes:", episodes.count,
                      "canLoadMore:", canLoadMore)
            }
            
            
            do {
                if offset == 0, let cachedData = try await cacheManager.loadCachedData() {
                    let newRows = processResult(dataObject: cachedData)
                    await MainActor.run {
                        self.episodes = newRows
                        self.offset = cachedData.data?.podcastUnionV2?.episodesV2?.pagingInfo?.nextOffset ?? 0
                        self.canLoadMore = !newRows.isEmpty
                    }
                    print("Дані завантажено з кешу.")
                } else {
                    print("Немає кешованих даних, завантажуємо з API.")
                    await fetchPodcastsFromAPI()
                }
            } catch {
                print("Помилка завантаження з кешу: \(error.localizedDescription)")
                await fetchPodcastsFromAPI()
            }
        }
    }
    
    // Loading data from the API
    func fetchPodcastsFromAPI() async {
        do {
            let result = try await service.fetchData(offset: offset, limit: limit)
            let newRows = processResult(dataObject: result)
            await MainActor.run {
                self.episodes += newRows
                self.offset = result.data?.podcastUnionV2?.episodesV2?.pagingInfo?.nextOffset ?? offset
                self.canLoadMore = !newRows.isEmpty
                print("✅ API fetched — newRows:", newRows.count,
                      "totalEpisodes:", episodes.count,
                      "nextOffset:", offset,
                      "canLoadMore:", canLoadMore)
            }
            
            if offset == limit {
                try await cacheManager.saveToCache(data: result)
                print("Дані завантажено з API та кешовано.")
            }
        } catch {
            errorMessage = "Помилка завантаження даних з API: \(error.localizedDescription)"
            print("Помилка завантаження з API: \(error.localizedDescription)")
        }
    }
    
    func refreshData() {
        offset = 0
        canLoadMore = true
        episodes = []
        loadData()
    }
}
