//
//  MainView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct MainView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: PodcastViewModel
    @State var topListViewModel: TopListViewModel
    @State private var debounceManager = DebounceManager()

    init(viewModel: PodcastViewModel, topListViewModel: TopListViewModel) {
        self.viewModel = viewModel
        self.topListViewModel = topListViewModel
    }

    var body: some View {
        @Bindable var coordinator = coordinator
        @Bindable var viewModel = viewModel
        NavigationStack(path: $coordinator.homePath) {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingLarge) {
                    AppBar(searchText: $viewModel.searchText)
                    TopList(viewModel: topListViewModel)
                    AllPodcastsList(viewModel: viewModel)
                }
            }
            .scrollIndicators(.hidden)
            .padding(.spacingMedium)
            .onAppear {
                viewModel.refreshData()
            }
            .onChange(of: viewModel.searchText) { _, _ in
                Task {
                    await debounceManager.debounce {
                        await MainActor.run { viewModel.applySearch() }
                    }
                }
            }
            .refreshable {
                viewModel.refreshData()
            }
            .navigationDestination(for: Place.self) { place in
                coordinator.view(for: place)
            }
        }
    }
}
