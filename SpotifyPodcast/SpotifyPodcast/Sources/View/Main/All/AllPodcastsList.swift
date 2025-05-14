//
//  AllList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 04.05.2025.
//

import SwiftUI

struct AllPodcastsList: View {
    @ObservedObject var viewModel: PodcastViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("All podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                LazyVStack {
                    ForEach(viewModel.isLoading ? PodcastEpisode.placeholder : viewModel.episodes) { podcast in
                        NavigationLink(value: podcast) {
                            PodcastRow(podcast: podcast)
                                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                .animation(.default, value: viewModel.isLoading)
                        }
                        .buttonStyle(.plain)
                    }
                }
        }
        .onAppear {
            viewModel.loadDataIfNeeded()
        }
    }
}

#Preview {
    AllPodcastsList(viewModel: PodcastViewModel())
}
