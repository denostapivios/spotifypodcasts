//
//  MainView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @State var viewModel: PodcastViewModel
    @State var topListViewModel: TopListViewModel
    @State private var searchText: String = ""

    @State private var debounceManager = DebounceManager()

    init(viewModel: PodcastViewModel, topListViewModel: TopListViewModel) {
        self.viewModel = viewModel
        self.topListViewModel = topListViewModel
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar(searchText: $viewModel.searchText)
                TopList(viewModel: topListViewModel)
                AllPodcastsList(viewModel: viewModel)
            }
        }
        .scrollIndicators(.hidden)
        .padding(16)
        .onAppear {
            viewModel.refreshData()
        }
        .onChange(of: viewModel.searchText) { _, newValue in
            Task {
                await debounceManager.debounce {
                    await MainActor.run {
                        viewModel.applySearch()
                    }
                }
            }
        }
        .refreshable {
            viewModel.refreshData()
        }
    }
}
