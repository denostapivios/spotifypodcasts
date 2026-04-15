//
//  PopularView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 06.05.2025.
//

import SwiftUI

struct PopularView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: PopularViewModel
    @State private var debounceManager = DebounceManager()

    init(viewModel: PopularViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        @Bindable var coordinator = coordinator
        @Bindable var viewModel = viewModel
        NavigationStack(path: $coordinator.popularPath) {
            ScrollView {
                VStack(alignment: .leading, spacing: .spacingLarge) {
                    AppBar(searchText: $viewModel.searchText)
                    PopularList(viewModel: viewModel)
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
            }
            .navigationDestination(for: Place.self) { place in
                coordinator.view(for: place)
            }
        }
    }
}
