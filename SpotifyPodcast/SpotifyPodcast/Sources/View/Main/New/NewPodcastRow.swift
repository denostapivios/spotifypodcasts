//
//  NewPodcastRow.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI

struct NewPodcastRow: View {
    @ObservedObject var viewModel: PodcastViewModel
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("New Releases")
                .font(.title2)
                .fontWeight(.bold)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 8) {
                    ForEach(viewModel.episodes.isEmpty ? PodcastEpisode.placeholder : viewModel.episodes) { podcast in
                        NavigationLink(value: podcast) {
                            NewItem(podcast: podcast)
                                .redacted(reason: viewModel.episodes.isEmpty ? .placeholder : [])
                                .animation(.default, value: viewModel.episodes.isEmpty)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 140)
            }
            .redacted(reason: viewModel.episodes.isEmpty ? .placeholder : [])
            .animation(.default, value: viewModel.episodes.isEmpty)
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    NewPodcastRow(viewModel: PodcastViewModel())
}
