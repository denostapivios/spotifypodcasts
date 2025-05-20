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
                AllPodcastsList(viewModel: viewModel)
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
