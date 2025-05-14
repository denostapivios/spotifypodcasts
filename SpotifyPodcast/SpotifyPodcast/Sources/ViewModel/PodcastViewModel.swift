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
    
    func loadDataIfNeeded() {
        guard !isLoading else { return }
        loadData()
    }
    
    func loadData() {
        isLoading = true
        
        Task {
            defer {
                Task { @MainActor in
                    self.isLoading = false
                }
            }
            
            do {
                if let cachedData = try await cacheManager.loadCachedData() {
                    let newRows = processResult(dataObject: cachedData)
                    await MainActor.run {
                        self.episodes = newRows
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
            let result = try await service.fetchData()
            let newRows = processResult(dataObject: result)
            await MainActor.run {
                self.episodes = newRows
            }
            try await cacheManager.saveToCache(data: result)
            print("Дані завантажено з API та кешовано.")
        } catch {
            errorMessage = "Помилка завантаження даних з API: \(error.localizedDescription)"
            print("Помилка завантаження з API: \(error.localizedDescription)")
        }
    }
    
    func refreshData() {
        isLoading = false
        loadData()
    }
}
