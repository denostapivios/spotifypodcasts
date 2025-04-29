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
    @Published var podcastResult: PodcastResponse?
    @Published var rows:[PodcastRow] = []
    var player: AVPlayer?
    
    private let cacheManager = CacheManager()
    private let service: PodcastServiceProtocol
    private let cacheKey = "cachedPodcasts"
    
    internal init(service: any PodcastServiceProtocol = PodcastService()) {
        self.service = service
    }
    
    enum PodcastImage: Hashable {
        case remote (URL)
        case local (String)
    }
    
    struct PodcastRow: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let image: PodcastImage
        let description: String
        let duration: Int
        let releaseDate: String
        let audioPreview: String
        let sharingInfo: String
        
    }

    func processResult(dataObject:PodcastResponse) -> [PodcastRow] {
        dataObject.data?.podcastUnionV2?.episodesV2?.items?.map { episodData in
            let image:PodcastImage
            if
                let imageString = episodData.entity?.data?.coverArt?.sources?.last?.url,
                let url = URL(string: imageString){
                image = .remote(url)
            } else {
                image = .local("photo")
            }
            let durationMilliseconds = episodData.entity?.data?.duration?.totalMilliseconds ?? 0
            let durationMinutes = durationMilliseconds / 60000
            // Convert duration to minutes
            
            let releaseDateIosString = episodData.entity?.data?.releaseDate?.isoString ?? "-"
            let formattedDate = ISO8601DateFormatter()
                .date(from: releaseDateIosString)
                .map { DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none) }
            ?? "Invalid date format"
            //Date conversion
            
            let audioLink = episodData.entity?.data?.audioPreview?.url ?? "-"
            // Audio
            
            return PodcastRow(
                title: episodData.entity?.data?.name ?? "-",
                image: image,
                description: episodData.entity?.data?.description ?? "-",
                duration: durationMinutes,
                releaseDate: formattedDate,
                audioPreview: audioLink,
                sharingInfo: episodData.entity?.data?.sharingInfo?.shareUrl ?? "-"
            )
        }
        ?? []
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
    
    func loadData() {
        Task {
            do {
                if let cachedData = try await cacheManager.loadCachedData() {
                    let newRows = processResult(dataObject: cachedData)
                    await MainActor.run {
                        self.rows = newRows
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
                self.rows = newRows
            }
            try await cacheManager.saveToCache(data: result)
            print("Дані завантажено з API та кешовано.")
        } catch {
            errorMessage = "Помилка завантаження даних з API: \(error.localizedDescription)"
            print("Помилка завантаження з API: \(error.localizedDescription)")
        }
    }
    
    func refreshData() {
        loadData()
    }
}
