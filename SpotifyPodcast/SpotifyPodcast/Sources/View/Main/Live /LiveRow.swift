//
//  LiveRow.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 20.03.2025.
//

import SwiftUI

struct LiveRow: View {
    @ObservedObject var viewModel: PodcastViewModel
    let rows = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Live Podcas")
                .font(.title2)
                .fontWeight(.bold)
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: rows, spacing: 8){
                    ForEach(viewModel.episodes.isEmpty ? PodcastEpisode.placeholder : viewModel.episodes) { podcast in
                        NavigationLink(value: podcast){
                            LiveItem(podcast: podcast)
                                .redacted(reason: viewModel.episodes.isEmpty ? .placeholder : [])
                                .animation(.default, value: viewModel.episodes.isEmpty)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 260)
            }
        }
        .onAppear {
            viewModel.loadDataIfNeeded()
        }
    }
}

#Preview {
    LiveRow(viewModel: PodcastViewModel())
}
