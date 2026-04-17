//
//  PlayerView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 16.04.2026.
//

import SwiftUI
import Kingfisher

struct PlayerView: View {
    @State var viewModel: PlayerViewModel

    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        VStack(spacing: 0) {
            closeButton
                .padding(.top, .spacingMedium)

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
        .task {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}

private extension PlayerView {

    var closeButton: some View {
        Button {
            coordinator.dismissPlayer()
        } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: .controlIconSize, weight: .semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    var image: some View {
        Group {
            switch viewModel.episode.image {
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
        .cornerRadius(.radiusSmall)
    }

    var titleLabel: some View {
        Text(viewModel.episode.title)
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
                            width: viewModel.totalTime > 0
                                ? geo.size.width * CGFloat(viewModel.currentTime / viewModel.totalTime)
                                : 0,
                            height: .progressBarHeight
                        )
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let ratio = value.location.x / geo.size.width
                            let time = viewModel.totalTime * Double(max(0, min(ratio, 1)))
                            viewModel.seekTo(time: time)
                        }
                )
            }
            .frame(height: .progressBarHeight)

            HStack {
                Text(formatTime(viewModel.currentTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatTime(viewModel.totalTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    var controls: some View {
        HStack(spacing: 0) {
            Button {
                viewModel.skipToPrevious()
            } label: {
                Image(systemName: "backward.end.fill")
                    .font(.system(size: .controlIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            Button {
                viewModel.seekBackward()
            } label: {
                Image(systemName: "gobackward.30")
                    .font(.system(size: .seekIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            if #available(iOS 26.0, *) {
                Button {
                    viewModel.togglePlay()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: .playIconSize))
                        .frame(width: .playButtonSize, height: .playButtonSize)
                }
                .glassEffect(.regular.interactive(), in: Circle())
                .frame(maxWidth: .infinity)
            } else {
                Button {
                    viewModel.togglePlay()
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: .playButtonSize, height: .playButtonSize)
                            .shadow(color: .black.opacity(0.12), radius: .shadowRadius, x: 0, y: .shadowY)
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: .playIconSize))
                            .foregroundColor(.primary)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Button {
                viewModel.seekForward()
            } label: {
                Image(systemName: "goforward.30")
                    .font(.system(size: .seekIconSize))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)

            Button {
                viewModel.skipToNext()
            } label: {
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
    let audioService = AudioPlayerService()
    let episode = PodcastEpisode.mock()
    let viewModel = PlayerViewModel(episode: episode, playlist: [episode], audioService: audioService)
    PlayerView(viewModel: viewModel)
        .environment(AppCoordinator())
}
