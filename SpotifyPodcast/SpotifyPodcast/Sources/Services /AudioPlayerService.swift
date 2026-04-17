//
//  AudioPlayerService.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 17.04.2026.
//

import Foundation
import AVFoundation

@MainActor
protocol AudioPlayerServiceProtocol: AnyObject {
    var isPlaying: Bool { get }
    var currentTime: Double { get }
    var duration: Double { get }

    func play(url: String)
    func pause()
    func resume()
    func togglePlay()
    func stop()
    func seekForward()
    func seekBackward()
    func seekTo(time: Double)
}

@Observable
@MainActor
final class AudioPlayerService: AudioPlayerServiceProtocol {

    var isPlaying: Bool = false
    var currentTime: Double = 0
    var duration: Double = 0

    private var player: AVPlayer?
    private var timeObserver: Any?

    func play(url: String) {
        guard let audioURL = URL(string: url) else { return }

        setupAudioSession()
        removeTimeObserver()
        player?.pause()

        let item = AVPlayerItem(url: audioURL)
        player = AVPlayer(playerItem: item)

        addTimeObserver()
        loadDuration(from: item)

        player?.play()
        isPlaying = true
        currentTime = 0
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        player?.play()
        isPlaying = true
    }

    func togglePlay() {
        isPlaying ? pause() : resume()
    }

    func stop() {
        removeTimeObserver()
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
    }

    func seekForward() {
        seek(by: 30)
    }

    func seekBackward() {
        seek(by: -30)
    }

    func seekTo(time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime)
        currentTime = time
    }
}

private extension AudioPlayerService {

    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AVAudioSession error: \(error)")
        }
    }

    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            MainActor.assumeIsolated {
                self?.currentTime = time.seconds
            }
        }
    }

    func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }

    func loadDuration(from item: AVPlayerItem) {
        Task { @MainActor in
            let duration = try? await item.asset.load(.duration)
            self.duration = duration?.seconds ?? 0
        }
    }

    func seek(by seconds: Double) {
        let newTime = max(0, min(currentTime + seconds, duration))
        seekTo(time: newTime)
    }
}
