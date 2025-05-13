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
            if !viewModel.episodes.isEmpty {
                Text("All podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                LazyVStack {
                    ForEach(viewModel.episodes) { podcast in
                        NavigationLink(value: podcast) {
                            PodcastRow(podcast: podcast)
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                Text("Завантаження...")
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
