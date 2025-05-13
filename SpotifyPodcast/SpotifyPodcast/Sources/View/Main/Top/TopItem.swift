//
//  PopularItem.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI
import Kingfisher

struct TopItem: View {
    var podcast: PodcastEpisode
    
    var body: some View {
        VStack(alignment: .leading) {
            switch podcast.image {
            case .placeholder(let imageName):
                Image(imageName)
                    .resizable()
                    .frame(width: 155, height: 155)
                    .cornerRadius(4)
                    .padding(.bottom, 4)
                
            case .remote(let url):
                KFImage(url)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .frame(width: 155, height: 155)
                    .cornerRadius(4)
                    .padding(.bottom, 4)
            }
            
            Text (podcast.title)
                .font(.callout)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: 155, alignment: .leading)
        }
    }
}

#Preview {
    TopItem(podcast: PodcastEpisode.mock)
    }
