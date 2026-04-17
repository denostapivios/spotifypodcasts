//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Foundation

@MainActor
final class PodcastViewModel: BasePodcastViewModel {

    override func sortEpisodes(_ episodes: [PodcastEpisode]) -> [PodcastEpisode] {
        episodes.sorted {
            guard let date1 = DateFormatter.mediumDate.date(from: $0.releaseDate),
                  let date2 = DateFormatter.mediumDate.date(from: $1.releaseDate) else {
                return false
            }
            return date1 > date2
        }
    }
}
