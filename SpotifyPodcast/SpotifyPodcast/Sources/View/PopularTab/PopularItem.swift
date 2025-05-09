//
//  PopularItem.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 05.05.2025.
//

import SwiftUI
import Kingfisher

struct PopularItem: View {
    var podcast: PodcastEpisode
    
    var body: some View {
        VStack(alignment: .leading) {
            GeometryReader { geometry in
                ZStack {
                    switch podcast.image {
                    case .placeholder(let imageName):
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                            .cornerRadius(4)
                        
                    case .remote(let url):
                        KFImage(url)
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                            .cornerRadius(4)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
            
            Text(podcast.title)
                .font(.callout)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    LiveItem(podcast: PodcastEpisode.mock)
}
