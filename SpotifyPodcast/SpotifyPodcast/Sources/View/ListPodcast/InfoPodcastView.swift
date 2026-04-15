//
//  InfoPodcastView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 15.03.2025.
//

import SwiftUI
import Kingfisher
import AVKit
import SwiftData

struct InfoPodcastView: View {
    @State var viewModel: PodcastViewModel
    let podcast: PodcastEpisode

    init(podcast: PodcastEpisode, viewModel: PodcastViewModel) {
        self.podcast = podcast
        self.viewModel = viewModel
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView {
            VStack {
                image
            }
            .padding(.bottom, .spacingMedium)

            title

            HStack(spacing: 10) {
                duration
                Spacer()
                releaseDate
            }
            .padding(.bottom, 10)

            VStack {
                HStack(spacing: 12) {
                    favoriteIcon

                    Spacer()

                    Button {
                        if let url = podcast.audioPreview {
                            viewModel.playAudio(from: url)
                        }
                    } label: {
                        HStack {
                            buttonImage
                            buttonText
                        }
                        .padding()
                        .frame(width: 120, height: 48)
                        .background(Color.green)
                        .cornerRadius(.radiusSmall)
                    }
                }
            }
            .padding(.bottom, 10)

            description
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.refreshData()
        }
        .sheet(isPresented: $viewModel.isPlayerPresented) {
            if let player = viewModel.player {
                AudioPlayerView(player: player)
            }
        }
    }
}

private extension InfoPodcastView {

    var title: some View {
        Text(podcast.title)
            .font(.system(size: 24))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var duration: some View {
        Text(podcast.duration)
            .font(.system(size: 14))
    }

    var releaseDate: some View {
        Text(podcast.releaseDate)
            .font(.system(size: 14))
    }

    var favoriteIcon: some View {
        Image(systemName: "star")
            .resizable()
            .scaledToFit()
            .frame(width: .iconMedium, height: .iconMedium)
    }

    var description: some View {
        Text(podcast.description)
            .multilineTextAlignment(.leading)
    }

    var buttonImage: some View {
        Image(systemName: "play.circle.fill")
            .foregroundColor(.white)
    }

    var buttonText: some View {
        Text("Play")
            .font(.system(size: 18))
            .fontWeight(.bold)
            .foregroundColor(.white)
    }

    var image: some View {
        switch podcast.image {
        case .remote(let url):
            return AnyView(
                KFImage(url)
                    .resizable()
                    .placeholder { ProgressView() }
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(.radiusSmall)
            )
        case .placeholder(let imageName):
            return AnyView(
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(.radiusSmall)
            )
        }
    }
}
