//
//  PlayerView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 16.04.2026.
//

import SwiftUI
import Kingfisher
import AVKit

struct PlayerView: View {
    let podcast: PodcastEpisode

    @State private var isPlaying = false
    @State private var currentTime: Double = 255
    @State private var totalTime: Double = 910

    var body: some View {
        VStack(spacing: 0) {
            image
                .padding(.top, .spacingLarge)

            titleLabel
                .padding(.top, .spacingLarge)

            progressSection
                .padding(.top, .spacingXXLarge)

            controls
                .padding(.top, .spacingLarge)

            Spacer()
        }
        .padding(.horizontal, .spacingLarge)
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

private extension PlayerView {

    var image: some View {
        Group {
            switch podcast.image {
            case .remote(let url):
                KFImage(url)
                    .resizable()
                    .placeholder { ProgressView() }
                    .scaledToFill()
            case .placeholder(let imageName):
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(.artworkCornerRadius)
    }

    var titleLabel: some View {
        Text(podcast.title)
            .font(.system(size: .titleFontSize, weight: .bold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    var progressSection: some View {
        VStack(spacing: .spacingSmall) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray4))
                        .frame(height: .progressBarHeight)
                    Capsule()
                        .fill(Color.primary)
                        .frame(
                            width: totalTime > 0
                                ? geo.size.width * CGFloat(currentTime / totalTime)
                                : 0,
                            height: .progressBarHeight
                        )
                }
            }
            .frame(height: .progressBarHeight)

            HStack {
                Text(formatTime(currentTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatTime(totalTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    var controls: some View {
        HStack(spacing: 0) {
            Button { } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: .controlIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            Button { } label: {
                Image(systemName: "gobackward.30")
                    .font(.system(size: .seekIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            if #available(iOS 26.0, *) {
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: .playIconSize))
                        .frame(width: .playButtonSize, height: .playButtonSize)
                }
                .glassEffect(.regular.interactive(), in: Circle())
                .frame(maxWidth: .infinity)
            } else {
                Button {
                    isPlaying.toggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: .playButtonSize, height: .playButtonSize)
                            .shadow(color: .black.opacity(0.12), radius: .shadowRadius, x: 0, y: .shadowY)
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: .playIconSize))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Button { } label: {
                Image(systemName: "goforward.30")
                    .font(.system(size: .seekIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            Button { } label: {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: .controlIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    func formatTime(_ seconds: Double) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

private extension CGFloat {
    static let artworkCornerRadius: CGFloat = 20
    static let titleFontSize: CGFloat = 24
    static let controlIconSize: CGFloat = 22
    static let seekIconSize: CGFloat = 26
    static let playIconSize: CGFloat = 28
    static let playButtonSize: CGFloat = 72
    static let progressBarHeight: CGFloat = 4
    static let shadowRadius: CGFloat = 8
    static let shadowY: CGFloat = 4
}


#Preview {
    PlayerView(podcast: .mock())
}
