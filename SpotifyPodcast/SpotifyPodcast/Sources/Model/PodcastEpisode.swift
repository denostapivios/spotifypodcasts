//
//  PodcastEpisodeUIModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 02.05.2025.
//

import Foundation

struct PodcastEpisode: Identifiable, Hashable, Equatable {
    let id: String
    let title: String
    let description: String
    let image: PodcastImage
    let durationMilliseconds: Int
    let releaseDate: String
    let audioPreview: String?
    let sharingInfo: String?
    
    var duration: String {
        let minutes = durationMilliseconds / 60000
        return "\(minutes) m"
    }
    
    init(
        id: String,
        title: String,
        description: String,
        image: PodcastImage,
        durationMillis: Int,
        releaseDate: String,
        audioPreview: String?,
        sharingInfo: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.durationMilliseconds = durationMillis
        self.releaseDate = releaseDate
        self.audioPreview = audioPreview
        self.sharingInfo = sharingInfo
    }
    
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
            .map { .remote($0) } ?? .placeholder("photo")
        
        let (millis) = Self.extractDuration(from: data)
        self.durationMilliseconds = millis
        
        self.releaseDate = data.releaseDate?.isoString
            .flatMap { ISO8601DateFormatter.shared.date(from: $0) }
            .map { DateFormatter.mediumDate.string(from: $0) } ?? "0.00.0000"
        
        self.audioPreview = data.audioPreview?.url
        self.sharingInfo = data.sharingInfo?.shareUrl
    }
    
    private static func extractDuration(from data: PodcastEpisodeData) -> (Int) {
        let millis = data.duration?.totalMilliseconds ?? 0
        return (millis)
    }
}

enum PodcastImage: Hashable {
    case remote (URL)
    case placeholder (String)
}

extension PodcastEpisode {
    static func mock(
        id: String = UUID().uuidString,
        title: String = "Mock Episode Title",
        description: String = "Mock description for preview.",
        image: PodcastImage = .placeholder("photo"),
        duration: String = "15 хв",
        durationMillis: Int = 1500000,
        releaseDate: String = "01.05.2024",
        audioPreview:String? = "https://example.com/audio.mp3",
        sharingInfo:String? = "https://example.com/share"
    ) -> PodcastEpisode {
        PodcastEpisode(
            id: id,
            title: title,
            description: description,
            image: image,
            durationMillis: durationMillis,
            releaseDate: releaseDate,
            audioPreview: audioPreview,
            sharingInfo: sharingInfo
        )
    }
    
    static func placeholder(count: Int = 5) -> [PodcastEpisode] {
        (0..<count).map { index in
            PodcastEpisode.mock(
                title: "Mock Episode \(index + 1)",
            )
        }
    }
}
