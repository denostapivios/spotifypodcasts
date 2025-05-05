//
//  AllList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 04.05.2025.
//

import SwiftUI

struct AllList: View {
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
                            AllItem(podcast: podcast)
                        }
                        .buttonStyle(.plain)
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
    AllList(viewModel: PodcastViewModel())
}
