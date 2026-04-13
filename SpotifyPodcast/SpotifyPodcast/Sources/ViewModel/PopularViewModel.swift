//
//  PopularViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 02.06.2025.
//

import Foundation

@MainActor
final class PopularViewModel: BasePodcastViewModel {
    override func sortEpisodes(_ episodes: [PodcastEpisode]) -> [PodcastEpisode] {
        episodes.sorted { $0.durationMilliseconds > $1.durationMilliseconds }
    }
}
