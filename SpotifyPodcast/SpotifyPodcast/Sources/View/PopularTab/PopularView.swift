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
    private let debounceManager = DebounceManager()
    
    init(viewModel: PopularViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar(searchText: $viewModel.searchText)
                PopularList(viewModel: viewModel)
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
        .onChange(of: viewModel.searchText) { _, newValue in
            Task {
                await debounceManager.debounce {
                    await MainActor.run {
                        viewModel.applySearch()
                    }
                }
            }
        }
    }
}
