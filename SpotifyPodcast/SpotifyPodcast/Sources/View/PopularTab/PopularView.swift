//
//  PopularView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 06.05.2025.
//

import SwiftUI

struct PopularView: View {
    @StateObject var viewModel = PodcastViewModel()
    @StateObject var searchViewModel = SearchListViewModel()
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar(searchText: $searchViewModel.searchText)
                PopularList(viewModel: viewModel)
            }
        }
        .scrollIndicators(.hidden)
        .padding(16)
        .refreshable {
            await viewModel.fetchPodcastsFromAPI()
        }
    }
}

#Preview {
    PopularView()
}
