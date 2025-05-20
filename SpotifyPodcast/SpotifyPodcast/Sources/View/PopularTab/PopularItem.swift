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
                let imageSize = geometry.size.width
                
                ZStack {
                    switch podcast.image {
                    case .placeholder(let imageName):
                        Image(imageName)
                            .resizable()
                        
                    case .remote(let url):
                        KFImage(url)
                            .resizable()
                            .placeholder {
                                ProgressView()
                            }
                    }
                }
                .scaledToFill()
                .frame(width: imageSize, height: imageSize)
                .clipped()
                .cornerRadius(4)
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
    PopularItem(podcast: PodcastEpisode.mock())
}
