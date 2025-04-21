//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Foundation
import AVKit

class PodcastViewModel: ObservableObject {
    
    @Published var isPlayerPresented = false
    @Published var errorMessage: String?
    var player: AVPlayer?
    
    private let cacheManager = CacheManager.shared  // Додаємо CacheManager для кешування
    private let service: PodcastServiceProtocol
    private let cacheKey = "cachedPodcasts"
    
    internal init(service: any PodcastServiceProtocol = PodcastService()) {
        self.service = service
        self.podcastResult = podcastResult
        self.rows = rows
    }
    
    enum PodcastImage: Hashable {
        case remoute (URL)
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
        
    }
    
    @Published var podcastResult: PodcastResponse?
    {
        willSet{
            objectWillChange.send()
        }
    }
    
    @Published var rows:[PodcastRow] = []
    
    func procesResult(dataObject:PodcastResponse) -> [PodcastRow] {
        
        dataObject.data?.podcastUnionV2?.episodesV2?.items?.map { episodData in
            let image:PodcastImage
            if
                let imageString = episodData.entity?.data?.coverArt?.sources?.last?.url,
                let url = URL(string: imageString){
                
                image = .remoute(url)
                
            } else {
                
                image = .local("photo")
            }
            // Перетворення тривалість в хв
            let durationMilliseconds = episodData.entity?.data?.duration?.totalMilliseconds ?? 0
            let durationMinutes = durationMilliseconds / 60000
            
            // Перетворення дати
            let releaseDateIosString = episodData.entity?.data?.releaseDate?.isoString ?? "-"
            let formattedDate = ISO8601DateFormatter()
                .date(from: releaseDateIosString)
                .map { DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .none) }
            ?? "Invalid date format"
            
            // audio
            let audioLink = episodData.entity?.data?.audioPreview?.url ?? "-"
            
            return PodcastRow(
                title: episodData.entity?.data?.name ?? "-",
                image: image,
                description: episodData.entity?.data?.description ?? "-",
                duration: durationMinutes,
                releaseDate: formattedDate,
                audioPreview: audioLink
                
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
                // Перевіряємо, чи є кешовані дані
                if let cachedData = try await cacheManager.loadCachedData() {
                    let newRows = procesResult(dataObject: cachedData)
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
                await fetchPodcastsFromAPI() // Якщо не вдалося завантажити з кешу, намагаємося знову з API
            }
        }
    }
    
    // Завантажуємо дані з API
    func fetchPodcastsFromAPI() async {
        
        do {
            let result = try await service.fetchData()
            let newRows = procesResult(dataObject: result)
            await MainActor.run {
                self.rows = newRows
            }
            
            // Оновлюємо кеш після завантаження з API
            try await cacheManager.saveToCache(data: result)
            print("Дані завантажено з API та кешовано.")
        } catch {
            errorMessage = "Помилка завантаження даних з API: \(error.localizedDescription)"
            print("Помилка завантаження з API: \(error.localizedDescription)")
        }
    }
    
    // Відслідковуємо зміну запиту для оновлення даних
    func queryChange() {
        loadData()
    }
    
    
    
}
