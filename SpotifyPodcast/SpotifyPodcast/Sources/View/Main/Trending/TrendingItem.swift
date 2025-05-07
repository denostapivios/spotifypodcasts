//
//  TrendingItem.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 20.03.2025.
//

import SwiftUI
import Kingfisher

struct TrendingItem: View {
    var podcast: PodcastEpisode
    
    var body: some View {
        VStack(alignment: .leading) {
            switch podcast.image {
            case .placeholder(let imageName):
                Image(imageName)
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(4)
                    .padding(.bottom, 4)
                
            case .remote(let url):
                KFImage(url)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .frame(width: 250, height: 250)
                    .cornerRadius(4)
                    .padding(.bottom, 4)
            }
            
            Text (podcast.title)
                .font(.callout)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 250, alignment: .leading)
        }
    }
}

#Preview {
    if let viewModel = PodcastEpisode(from: .mock) {
        TrendingItem(podcast: viewModel)
    } else {
        Text("Failed to init PodcastEpisodeUIModel from mock")
    }
}
