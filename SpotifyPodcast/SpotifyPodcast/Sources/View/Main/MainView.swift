//
//  MainView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = PodcastViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar()
                PopularPodcastRow(viewModel: viewModel)
                NewPodcastRow(viewModel: viewModel)
                TrendingRow(viewModel: viewModel)
                LiveRow(viewModel: viewModel)
            }
        }
        .padding(16)
        .refreshable {
            await viewModel.fetchPodcastsFromAPI()
        }
    }
}

#Preview {
    MainView()
}
