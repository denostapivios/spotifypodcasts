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
            if !viewModel.episodes.isEmpty {
                Text("Live Podcas")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 8){
                        ForEach(viewModel.episodes) { podcast in
                            NavigationLink(value: podcast){
                                LiveItem(podcast: podcast)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 260)
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
    LiveRow(viewModel: PodcastViewModel())
}
