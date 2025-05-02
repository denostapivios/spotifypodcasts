//
//  TrendingRow.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 20.03.2025.
//

import SwiftUI

struct TrendingRow: View {
    @ObservedObject var viewModel: PodcastViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.episodes.isEmpty {
                Text("Trending")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.episodes) { podcast in
                            NavigationLink(value: podcast) {
                                PopularItem(podcast: podcast)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                Text("Завантаження...")
            }
        }
        .onAppear {
            viewModel.refreshData()  
        }
    }
}

#Preview {
    TrendingRow(viewModel: PodcastViewModel())
}
