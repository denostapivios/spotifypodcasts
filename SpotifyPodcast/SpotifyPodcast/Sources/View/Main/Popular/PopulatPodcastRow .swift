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
            if viewModel.rows.count > 0 {
                Text("Popupular Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.rows) { podcast in
                            NavigationLink(value: podcast) {
                                PopularItem(podcast: podcast)
                            }
                            .buttonStyle(.plain)
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
