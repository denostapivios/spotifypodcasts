//
//  AllItem.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 04.05.2025.
//

import SwiftUI
import Kingfisher

struct PodcastRow: View {
    var podcast: PodcastEpisode
    
    var body: some View {
        VStack(spacing:10) {
            HStack(spacing:12) {
                image
                title
                Spacer()
            }
            description
            
            HStack(spacing:12) {
                favoriteIcon
                Spacer()
                duration
            }
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.top, 6)
        }
        .padding(.vertical, 3)
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
                    .frame(width: 50, height: 50)
                    .cornerRadius(.radiusSmall)
            )
        case .placeholder(let imageName):
            return AnyView(
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(.radiusSmall)
            )
        }
    }
    
    var title: some View {
        Text(podcast.title)
            .font(.system(size: 18))
            .multilineTextAlignment(.leading)
    }
    
    var description: some View {
        Text(podcast.description)
            .font(.system(size: 12))
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .foregroundColor(Color(red: 98/255.0, green: 98/255.0, blue: 98/255.0))
    }
    
    var favoriteIcon: some View {
        Image(systemName: "star")
            .resizable()
            .scaledToFit()
            .frame(width: .iconMedium, height: .iconMedium)
    }
    
    var duration: some View {
        Text(podcast.duration)
            .font(.system(size: 14))
    }
}

#Preview {
    PodcastRow(podcast: .mock())
}
