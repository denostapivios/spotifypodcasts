//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Foundation
import AVKit
import AVFoundation

@MainActor
final class PodcastViewModel: BasePodcastViewModel {
    var isPlayerPresented = false
    var player: AVPlayer?

    func playAudio(from urlString: String) {
        guard let url = URL(string: urlString), urlString != "-" else {
            print("Invalid audio URL")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
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
