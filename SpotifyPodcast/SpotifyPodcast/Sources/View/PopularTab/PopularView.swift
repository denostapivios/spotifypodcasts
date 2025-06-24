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
    
    private let debounceManager = DebounceManager()
    
    init(viewModel: PopularViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar(searchText: $searchViewModel.searchText)
                PopularList(viewModel: viewModel, searchViewModel: searchViewModel)
            }
        }
        .scrollIndicators(.hidden)
        .padding(16)
        .task {
            viewModel.loadData()
        }
        .refreshable {
            viewModel.refreshData()
        }
        .onChange(of: searchViewModel.searchText) { _, newValue in
            Task {
                await debounceManager.debounce {
                    searchViewModel.filterPodcast()
                }
            }
        }
    }
}
