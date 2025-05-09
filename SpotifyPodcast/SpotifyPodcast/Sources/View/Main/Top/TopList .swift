//
//  PopulatPodcastRow .swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI

struct TopList: View {
    @ObservedObject var viewModel: PodcastViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("Top Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.episodes.isEmpty ? PodcastEpisode.placeholder : viewModel.episodes) { podcast in
                            NavigationLink(value: podcast) {
                                TopItem(podcast: podcast)
                                    .redacted(reason: viewModel.episodes.isEmpty ? .placeholder : [])
                                    .animation(.default, value: viewModel.episodes.isEmpty)
                            }
                            .buttonStyle(.plain)
                        }
                }
                .frame(height: 185)
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    TopList(viewModel: PodcastViewModel())
}
