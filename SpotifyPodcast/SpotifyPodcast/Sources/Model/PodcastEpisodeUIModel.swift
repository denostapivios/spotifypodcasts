//
//  PodcastEpisodeUIModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 02.05.2025.
//

import Foundation

struct PodcastEpisodeUIModel: Identifiable,Hashable {
    let id: String
    let title: String
    let description: String
    let image: PodcastImage
    let duration: String
    let releaseDate: String
    let audioPreview: String?
    let sharingInfo: String?
    
    init?(from item: PodcastItem) {
        guard let data = item.entity?.data,
              let id = data.id,
              let name = data.name,
              let description = data.description,
              let imageUrl = data.coverArt?.sources?.last?.url,
              let duration = data.duration?.totalMilliseconds,
              let releaseDate = data.releaseDate?.isoString else {
            return nil
        }
        
        self.id = id
        self.title = name
        self.description = description
        
        self.image = URL(string: imageUrl)
            .map { .remote($0) } ?? .local("photo")
        
        self.duration = "\(duration / 60000) m"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        self.releaseDate = ISO8601DateFormatter().date(from: releaseDate)
            .map { formatter.string(from: $0) } ?? String(releaseDate.prefix(10))
        
        self.audioPreview = data.audioPreview?.url
        self.sharingInfo = data.sharingInfo?.shareUrl
    }
}

enum PodcastImage: Hashable {
    case remote (URL)
    case local (String)
}

extension PodcastItem {
    static var mock: PodcastItem {
        PodcastItem(
            uid: "mock-uid",
            entity: PodcastEntity(
                data: PodcastEpisodeData(
                    id: "1",
                    name: "Mock Episode Title",
                    description: "Mock description for preview.",
                    coverArt: CoverArt(sources: [
                        CoverSource(url: "https://via.placeholder.com/150")
                    ]),
                    duration: Duration(totalMilliseconds: 900_000), // 15 хв
                    releaseDate: ReleaseDate(isoString: "2024-05-01T12:00:00Z"),
                    audioPreview: AudioPreview(url: "https://example.com/audio.mp3"),
                    sharingInfo: SharingInfo(shareUrl: "https://example.com/share")
                )
            )
        )
    }
}
