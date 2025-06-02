//
//  PopularView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 06.05.2025.
//

import SwiftUI
import SwiftData

struct PopularView: View {
    @StateObject var viewModel: PopularViewModel
    @StateObject var searchViewModel = SearchListViewModel()
    
    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: PopularViewModel(modelContext: context))
    }
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar(searchText: $searchViewModel.searchText)
                PopularList(viewModel: viewModel)
            }
        }
        .scrollIndicators(.hidden)
        .padding(16)
        .refreshable {
            await viewModel.fetchPodcastsFromAPI()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CachedPodcast.self, configurations: config)
    return PopularView(context: container.mainContext)
}
