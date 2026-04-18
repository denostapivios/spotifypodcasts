//
//  AllItem.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 04.05.2025.
//

import SwiftUI
import Kingfisher

struct PodcastRow: View {
    @Environment(AppCoordinator.self) private var coordinator
    var podcast: PodcastEpisode

    var body: some View {
        VStack(spacing: .spacingBase) {
            HStack(spacing: .spacingItem) {
                image
                title
                Spacer()
            }
            description

            HStack(spacing: .spacingItem) {
                favoriteIcon
                Spacer()
                duration
            }
            Divider()
                .background(Color.gray.opacity(.dividerOpacity))
                .padding(.top, .dividerTopPadding)
        }
        .padding(.vertical, .rowVerticalPadding)
    }
}

private extension PodcastRow {
    
    var image: some View {
        switch podcast.image {
        case .remote(let url):
            return AnyView(
                KFImage(url)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .scaledToFit()
                    .frame(width: .podcastThumbnail, height: .podcastThumbnail)
                    .cornerRadius(.radiusSmall)
            )
        case .placeholder(let imageName):
            return AnyView(
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: .podcastThumbnail, height: .podcastThumbnail)
                    .cornerRadius(.radiusSmall)
            )
        }
    }
    
    var title: some View {
        Text(podcast.title)
            .font(.system(size: .fontSizeBody))
            .multilineTextAlignment(.leading)
    }

    var description: some View {
        Text(podcast.description)
            .font(.system(size: .fontSizeCaption))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .foregroundColor(.descriptionGray)
    }
    
    var favoriteIcon: some View {
        let isFav = coordinator.favoriteViewModel?.isFavorite(podcast) ?? false
        return Button {
            coordinator.favoriteViewModel?.toggleFavorite(podcast)
        } label: {
            Image(systemName: isFav ? "star.fill" : "star")
                .resizable()
                .scaledToFit()
                .frame(width: .iconMedium, height: .iconMedium)
                .foregroundColor(isFav ? .orange : .primary)
                .symbolEffect(.bounce, value: isFav)
                .animation(.easeInOut(duration: .starAnimationDuration), value: isFav)
        }
        .buttonStyle(.plain)
    }
    
    var duration: some View {
        Text(podcast.duration)
            .font(.system(size: .fontSizeSecondary))
    }
}

private extension CGFloat {
    static let dividerTopPadding: CGFloat = 6
    static let rowVerticalPadding: CGFloat = 3
}

private extension Double {
    static let dividerOpacity: Double = 0.3
    static let starAnimationDuration: Double = 0.2
}

private extension Color {
    static let descriptionGray = Color(red: 98/255.0, green: 98/255.0, blue: 98/255.0)
}

#Preview {
    PodcastRow(podcast: .mock())
        .environment(AppCoordinator())
}
