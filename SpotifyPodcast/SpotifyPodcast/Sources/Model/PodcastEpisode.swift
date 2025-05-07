//
//  PodcastEpisodeUIModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 02.05.2025.
//

import Foundation

struct PodcastEpisode: Identifiable,Hashable {
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
              let id = data.id else {
            return nil
        }
        
        self.id = id
        self.title = data.name ?? "Name podcast"
        self.description = data.description ?? "Description podcast"
        
        self.image = data.coverArt?.sources?.last?.url
            .flatMap { URL(string: $0) }
            .map { .remote($0) } ?? .local("photo")
        
        self.duration = data.duration?.totalMilliseconds
            .map { "\($0 / 60000) m" } ?? "0 m"
        
        self.releaseDate = data.releaseDate?.isoString
            .flatMap { ISO8601DateFormatter.shared.date(from: $0) }
            .map { DateFormatter.mediumDate.string(from: $0) } ?? "0.00.0000"
        
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
