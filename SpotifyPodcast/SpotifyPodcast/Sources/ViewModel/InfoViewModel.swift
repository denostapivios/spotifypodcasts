//
//  InfoViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 30.07.2025.
//

import Foundation
import SwiftData
import AVKit

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var isPlayerPresented = false
    @Published var episodes: PodcastEpisode
    
    var player: AVPlayer?
    
    init(episodes: PodcastEpisode) {
        self.episodes = episodes
    }
    
    func playAudio(from urlString: String) {
        guard let url = URL(string: urlString), urlString != "-" else {
            print("Invalid audio URL")
            return
        }
        player = AVPlayer(url: url)
        player?.play()
        isPlayerPresented = true
    }
    
    func pause() {
            player?.pause()
            isPlayerPresented = false
        }
        
    deinit {
        player?.pause()
        player = nil
    }
    
}
