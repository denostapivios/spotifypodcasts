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
        @Bindable var topListViewModel = topListViewModel
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
            .task {
                await viewModel.loadIfNeeded()
            }
            .task(id: viewModel.searchText) {
                await viewModel.applySearchWithDebounce()
            }
            .refreshable {
                await viewModel.forceRefresh()
                await topListViewModel.forceRefresh()
            }
            .navigationDestination(for: Place.self) { place in
                coordinator.view(for: place)
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert("Something went wrong", isPresented: Binding(
                get: { topListViewModel.errorMessage != nil },
                set: { if !$0 { topListViewModel.errorMessage = nil } }
            )) {
                Button("OK") { topListViewModel.errorMessage = nil }
            } message: {
                Text(topListViewModel.errorMessage ?? "")
            }
        }
    }
}
