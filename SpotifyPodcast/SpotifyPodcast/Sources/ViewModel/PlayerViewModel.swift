//
//  PlayerViewModel.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 17.04.2026.
//

import Foundation

@Observable
@MainActor
final class PlayerViewModel {

    private(set) var episode: PodcastEpisode
    private let playlist: [PodcastEpisode]
    private let audioService: any AudioPlayerServiceProtocol

    var isPlaying: Bool { audioService.isPlaying }
    var currentTime: Double { audioService.currentTime }
    var totalTime: Double { audioService.duration }

    private var currentIndex: Int {
        playlist.firstIndex(of: episode) ?? 0
    }

    init(episode: PodcastEpisode, playlist: [PodcastEpisode], audioService: any AudioPlayerServiceProtocol) {
        self.episode = episode
        self.playlist = playlist.isEmpty ? [episode] : playlist
        self.audioService = audioService
    }

    func start() {
        guard let url = episode.audioPreview else { return }
        audioService.play(url: url)
    }

    func togglePlay() {
        audioService.togglePlay()
    }

    func seekForward() {
        audioService.seekForward()
    }

    func seekBackward() {
        audioService.seekBackward()
    }

    func seekTo(time: Double) {
        audioService.seekTo(time: time)
    }

    func skipToNext() {
        let next = currentIndex + 1
        guard next < playlist.count else { return }
        episode = playlist[next]
        guard let url = episode.audioPreview else { return }
        audioService.play(url: url)
    }

    func skipToPrevious() {
        if audioService.currentTime > 3 {
            audioService.seekTo(time: 0)
        } else {
            let prev = currentIndex - 1
            guard prev >= 0 else {
                audioService.seekTo(time: 0)
                return
            }
            episode = playlist[prev]
            guard let url = episode.audioPreview else { return }
            audioService.play(url: url)
        }
    }

    func stop() {
        audioService.stop()
    }
}
