//
//  PopularView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 06.05.2025.
//

import SwiftUI
import SwiftData

struct PopularView: View {
//    @Environment(\.modelContext) private var modelContext
    
    @StateObject var viewModel: PopularViewModel
    @StateObject var searchViewModel = SearchListViewModel()
    
//    @State private var searchText1: String = ""
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
        // 1. Перший автозапуск loadData()
                .task {
                    viewModel.loadData()
                }
        // 2. Pull to refresh
        .refreshable {
            viewModel.refreshData()
        }
        // 3. Дебаунс для фільтрації
        .onChange(of: searchViewModel.searchText) { _, newValue in
            Task {
                await debounceManager.debounce {
                   
                        searchViewModel.filterPodcast()
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CachedPodcast.self, configurations: config)
    let viewModel = PopularViewModel(modelContext: container.mainContext)
    PopularView(viewModel: viewModel)
}
