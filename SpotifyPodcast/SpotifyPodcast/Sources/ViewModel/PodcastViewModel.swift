//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Foundation
import AVKit
//import SwiftData

@MainActor
final class PodcastViewModel: BasePodcastViewModel {
    @Published var isPlayerPresented = false
    var player: AVPlayer?

    func playAudio(from urlString: String) {
        guard let url = URL(string: urlString), urlString != "-" else {
            print("Invalid audio URL")
            return
        }
        player = AVPlayer(url: url)
        player?.play()
        isPlayerPresented = true
    }

    deinit {
        player?.pause()
        player = nil
    }

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
