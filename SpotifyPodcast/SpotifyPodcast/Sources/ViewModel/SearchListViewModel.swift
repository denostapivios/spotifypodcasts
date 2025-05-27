//
//  SearchListViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 23.05.2025.
//

import Foundation

class SearchListViewModel: ObservableObject {
    @Published var episodes: [PodcastEpisode] = []
    @Published var searchText: String = ""
    
    private let service: PodcastServiceProtocol
    private var allEpisodes: [PodcastEpisode] = []
    
    internal init(service: any PodcastServiceProtocol = PodcastService()) {
        self.service = service
    }
    
    func updatePodcast(with newEpisodes: [PodcastEpisode]) {
        self.allEpisodes = newEpisodes
        filterPodcast()
    }
    
    func filterPodcast() {
        guard !searchText.isEmpty else {
            episodes = allEpisodes
            return
        }
        
        episodes = allEpisodes.filter { episode in
            episode.title.localizedCaseInsensitiveContains(searchText)
            || episode.description.localizedCaseInsensitiveContains(searchText)
        }
    }
}
