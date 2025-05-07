//
//  NewItem.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI
import Kingfisher

struct NewItem: View {
    var podcast: PodcastEpisode
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                switch podcast.image {
                case .placeholder(let imageName):
                    Image(imageName)
                        .resizable()
                        .frame(width: 64, height: 64)
                        .cornerRadius(4)
                    
                case .remote(let url):
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .frame(width: 64, height: 64)
                        .cornerRadius(4)
                }
                
                VStack(alignment: .leading) {
                    Text(podcast.title)
                        .font(.callout)
                        .lineLimit(1)
                        .padding(.bottom,8)
                    Text(podcast.description)
                        .font(.caption)
                        .foregroundColor(Color(red: 98/255.0, green: 98/255.0, blue: 98/255.0))
                        .lineLimit(2)
                }
                
                Spacer()
                
                Image(systemName: "ellipsis")
            }
        }
        .frame(width: 328)
    }
}

#Preview {
        NewItem(podcast: PodcastEpisode.mock)
}
