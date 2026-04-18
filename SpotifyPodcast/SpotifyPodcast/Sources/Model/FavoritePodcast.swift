//
//  FavoritePodcast.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 18.04.2026.
//

import Foundation
import SwiftData

@Model
class FavoritePodcast {
    var id: String
    var title: String
    var descriptionText: String
    var imageURL: String?
    var durationMilliseconds: Int
    var releaseDate: String
    var audioPreview: String?
    var sharingInfo: String?
    var addedAt: Date

    init(from episode: PodcastEpisode) {
        self.id = episode.id
        self.title = episode.title
        self.descriptionText = episode.description
        self.durationMilliseconds = episode.durationMilliseconds
        self.releaseDate = episode.releaseDate
        self.audioPreview = episode.audioPreview
        self.sharingInfo = episode.sharingInfo
        self.addedAt = .now

        if case .remote(let url) = episode.image {
            self.imageURL = url.absoluteString
        }
    }

    func toPodcastEpisode() -> PodcastEpisode {
        let image: PodcastImage = imageURL.flatMap { URL(string: $0) }
            .map { .remote($0) } ?? .placeholder("photo")

        return PodcastEpisode(
            id: id,
            title: title,
            description: descriptionText,
            image: image,
            durationMillis: durationMilliseconds,
            releaseDate: releaseDate,
            audioPreview: audioPreview,
            sharingInfo: sharingInfo
        )
    }
}
