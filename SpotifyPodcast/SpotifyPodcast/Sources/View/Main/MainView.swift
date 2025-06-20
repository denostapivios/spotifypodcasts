//
//  MainView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    
    @StateObject var viewModel: PodcastViewModel
    @StateObject var topListViewModel: TopListViewModel
    @StateObject var searchViewModel = SearchListViewModel()
    
    @State private var searchText: String = ""
    private let debounceManager = DebounceManager()
    
    init(viewModel: PodcastViewModel, topListViewModel: TopListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _topListViewModel = StateObject(wrappedValue: topListViewModel)
    }
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar(searchText: $searchViewModel.searchText)
                TopList(viewModel: topListViewModel)
                AllPodcastsList(viewModel: viewModel, searchViewModel: searchViewModel)
            }
        }
        .scrollIndicators(.hidden)
        .padding(16)
        .onAppear {
            viewModel.refreshData()
        }
        .onChange(of: searchViewModel.searchText) { _, newValue in
            Task {
                await debounceManager.debounce {
                    await MainActor.run {
                        searchViewModel.filterPodcast()
                    }
                }
            }
        }
        .refreshable {
            viewModel.refreshData()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CachedPodcast.self, configurations: config)
    let viewModel = PodcastViewModel(modelContext: container.mainContext)
    let topViewModel = TopListViewModel(modelContext: container.mainContext)
    MainView(viewModel: viewModel, topListViewModel: topViewModel)
}
