//
//  PopularList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 05.05.2025.
//

import SwiftUI

struct PopularList: View {
    
    @StateObject var viewModel = PodcastViewModel()
    let columns = [
        GridItem(.flexible(),spacing: 16),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.episodes.isEmpty {
                Text("Popular Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.episodes) { podcast in
                            NavigationLink(value: podcast){
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
    PopularList(viewModel:PodcastViewModel())
}
