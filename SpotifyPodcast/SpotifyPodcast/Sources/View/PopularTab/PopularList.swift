//
//  PopularList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 05.05.2025.
//

import SwiftUI
import SwiftData

struct PopularList: View {
    @ObservedObject var viewModel: PodcastViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Popular Podcasts")
                .font(.title2)
                .fontWeight(.bold)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.isLoading ? PodcastEpisode.placeholder() : viewModel.episodes) { podcast in
                        NavigationLink(value: podcast){
                            PopularItem(podcast: podcast)
                                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                .animation(.default, value: viewModel.isLoading)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CachedPodcast.self, configurations: config)
    let viewModel = PodcastViewModel(modelContext: container.mainContext)
    return PopularList(viewModel: viewModel)
}
