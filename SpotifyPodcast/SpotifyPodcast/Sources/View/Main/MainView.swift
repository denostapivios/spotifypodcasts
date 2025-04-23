//
//  MainView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                AppBar()
                PopulatPodcastRow()
                NewPodcastRow()
                TrendingRow()
                LiveRow()
            }
        }
        .padding(16)
    }
}

#Preview {
    MainView()
}
