//
//  PopulatPodcastRow .swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI

struct PopularPodcastRow: View {
    @ObservedObject var viewModel: PodcastViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if !viewModel.episodes.isEmpty {
                Text("Top Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.episodes) { podcast in
                            NavigationLink(value: podcast) {
                                PopularItem(podcast: podcast)
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 8)
                        }
                        
                    }
                   
                    .frame(height: 185)
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
    PopularPodcastRow(viewModel: PodcastViewModel())
}
