//
//  MainView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = PodcastViewModel()
    @StateObject var topListViewModel = TopListViewModel()
    @StateObject var searchViewModel = SearchListViewModel()
    
    @State private var searchText: String = ""
    private let debounceManager = DebounceManager()
    
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
            debounceManager.debounce {
                searchViewModel.filterPodcast()
            }
        }
        .refreshable {
            viewModel.refreshData()
        }
    }
}

#Preview {
    MainView()
}
