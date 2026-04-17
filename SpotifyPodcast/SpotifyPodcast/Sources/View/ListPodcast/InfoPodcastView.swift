//
//  InfoPodcastView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 15.03.2025.
//

import SwiftUI
import Kingfisher
import SwiftData

struct InfoPodcastView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: PodcastViewModel
    let podcast: PodcastEpisode
    let episodes: [PodcastEpisode]

    init(podcast: PodcastEpisode, episodes: [PodcastEpisode], viewModel: PodcastViewModel) {
        self.podcast = podcast
        self.episodes = episodes
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack {
                image
            }
            .padding(.bottom, .spacingMedium)

            title

            HStack(spacing: .itemSpacing) {
                duration
                Spacer()
                releaseDate
            }
            .padding(.bottom, .itemSpacing)

            VStack {
                HStack(spacing: .actionRowSpacing) {
                    favoriteIcon

                    Spacer()

                    Button {
                        coordinator.navigateTo(place: .player(podcast, episodes))
                    } label: {
                        HStack {
                            buttonImage
                            buttonText
                        }
                        .padding()
                        .frame(width: .playButtonWidth, height: .playButtonHeight)
                        .background(Color.green)
                        .cornerRadius(.radiusSmall)
                    }
                }
            }
            .padding(.bottom, .itemSpacing)

            description
                .padding(.bottom, .itemSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding()
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

private extension InfoPodcastView {

    var title: some View {
        Text(podcast.title)
            .font(.system(size: .titleFontSize))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .padding(.bottom, .itemSpacing)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    var duration: some View {
        Text(podcast.duration)
            .font(.system(size: .secondaryFontSize))
    }

    var releaseDate: some View {
        Text(podcast.releaseDate)
            .font(.system(size: .secondaryFontSize))
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
            .font(.system(size: .buttonFontSize))
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
                    .frame(width: .artworkSize, height: .artworkSize)
                    .cornerRadius(.radiusSmall)
            )
        case .placeholder(let imageName):
            return AnyView(
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: .artworkSize, height: .artworkSize)
                    .cornerRadius(.radiusSmall)
            )
        }
    }
}

private extension CGFloat {
    static let itemSpacing: CGFloat = 10
    static let actionRowSpacing: CGFloat = 12
    static let playButtonWidth: CGFloat = 120
    static let playButtonHeight: CGFloat = 48
    static let titleFontSize: CGFloat = 24
    static let secondaryFontSize: CGFloat = 14
    static let buttonFontSize: CGFloat = 18
    static let artworkSize: CGFloat = 300
}
