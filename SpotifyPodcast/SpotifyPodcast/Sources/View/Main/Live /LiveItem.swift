//
//  LiveItem.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 20.03.2025.
//

import SwiftUI
import Kingfisher

struct LiveItem: View {
    var podcast: PodcastViewModel.PodcastRow
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                switch podcast.image {
                case .local(let imageName):
                    Image(imageName)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(4)
                        .padding(.bottom, 4)
                    
                case .remote(let url):
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .frame(width: 80, height: 80)
                        .cornerRadius(4)
                        .padding(.bottom, 4)
                }
                
                Text (podcast.title)
                    .font(.footnote)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 80, alignment: .leading)
            }
            .frame(width: 80)
        }
    }
}

#Preview {
    LiveItem(podcast: PodcastViewModel.PodcastRow (
        title: "This is a description of the sample podcast.",
        image: .local("photo"),
        description: "This is a description of the sample podcast.",
        duration: 60,
        releaseDate: "01.01.0001",
        audioPreview: "-"
    ))
}
