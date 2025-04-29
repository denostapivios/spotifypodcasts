//
//  PodcastResponse.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 28.02.2025.
//

import Foundation

struct PodcastResponse: Codable {
    let data: PodcastData?
}

struct PodcastData: Codable {
    let podcastUnionV2: PodcastUnionV2?
}

struct PodcastUnionV2: Codable {
    let episodesV2: EpisodesV2?
}

struct EpisodesV2: Codable {
    let items: [PodcastItem]?
}

struct PodcastItem: Codable {
    let uid: String?
    let entity: PodcastEntity?
}

struct PodcastEntity: Codable {
    let data: PodcastEpisodeData?
}

struct PodcastEpisodeData: Codable {
    let id: String?
    let name: String?
    let description: String?
    let coverArt: CoverArt?
    let duration: Duration?
    let releaseDate: ReleaseDate?
    let audioPreview: AudioPreview?
    let sharingInfo: SharingInfo?
}

struct CoverArt: Codable {
    let sources: [CoverSource]?
}

struct CoverSource: Codable {
    let url: String?
}

struct Duration: Codable {
    let totalMilliseconds: Int?
}

struct ReleaseDate: Codable {
    let isoString: String?
}

struct AudioPreview: Codable {
    let url: String?
}

struct SharingInfo: Codable {
    let shareUrl: String?
}
