//
//  SearchService.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 24.06.2025.
//

import Foundation

final class SearchService {
    func filter(_ episodes: [PodcastEpisode], by text: String) -> [PodcastEpisode] {
        guard !text.isEmpty else { return episodes }
        
        return episodes.filter {
            $0.title.localizedCaseInsensitiveContains(text)
        }
    }
}
