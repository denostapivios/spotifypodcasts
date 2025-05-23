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
        .refreshable {
            viewModel.refreshData()
        }
    }
}

#Preview {
    MainView()
}
