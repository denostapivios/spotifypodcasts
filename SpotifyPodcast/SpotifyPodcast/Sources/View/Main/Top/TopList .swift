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
                        ForEach(viewModel.isLoading ? PodcastEpisode.placeholder : viewModel.episodes) { podcast in
                            NavigationLink(value: podcast) {
                                TopItem(podcast: podcast)
                                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                    .animation(.default, value: viewModel.isLoading)
                            }
                            .buttonStyle(.plain)
                        }
                }
                .frame(height: 185)
            }
        }
        .onAppear {
            viewModel.loadDataIfNeeded()
        }
    }
}

#Preview {
    TopList(viewModel: PodcastViewModel())
}
