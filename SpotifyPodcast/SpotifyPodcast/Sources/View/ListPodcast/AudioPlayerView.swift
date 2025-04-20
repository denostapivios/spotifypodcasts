//
//  AudioPlayerView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 30.03.2025.
//

import SwiftUI
import AVKit

struct AudioPlayerView: UIViewControllerRepresentable {
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
