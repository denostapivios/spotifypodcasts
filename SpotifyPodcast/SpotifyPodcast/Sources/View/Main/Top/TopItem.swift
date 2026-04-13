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
    
    private let size: CGFloat = 155
    
    var body: some View {
        VStack(alignment: .leading) {
            switch podcast.image {
            case .placeholder(let imageName):
                Image(imageName)
                    .resizable()
                    .frame(width: size, height: size)
                    .cornerRadius(.radiusSmall)
                    .padding(.bottom, .spacingXSmall)
                
            case .remote(let url):
                KFImage(url)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .frame(width: size, height: size)
                    .cornerRadius(.radiusSmall)
                    .padding(.bottom, .spacingXSmall)
            }
            
            Text (podcast.title)
                .font(.callout)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(width: size, alignment: .leading)
        }
    }
}
