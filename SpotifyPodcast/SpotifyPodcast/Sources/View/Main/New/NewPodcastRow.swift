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
            if viewModel.rows.count > 0 {
                Text("New Releases")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: rows, spacing: 8) {
                        ForEach(viewModel.rows) { podcast in
                            NavigationLink(value: podcast) {
                                NewItem(podcast: podcast)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 140)
                }
            }
            else {
                Text("Завантаження...")
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    NewPodcastRow(viewModel: PodcastViewModel())
}
