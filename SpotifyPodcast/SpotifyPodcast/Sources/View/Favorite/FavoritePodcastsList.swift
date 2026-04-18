//
//  FavoritePodcastsList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 18.04.2026.
//

import SwiftUI

struct FavoritePodcastsList: View {
    @Environment(AppCoordinator.self) private var coordinator
    var viewModel: FavoriteViewModel

    var body: some View {
        VStack(alignment: .leading) {
            LazyVStack {
                ForEach(viewModel.favorites, id: \.id) { podcast in
                    Button {
                        coordinator.navigateTo(place: .detail(podcast, viewModel.favorites))
                    } label: {
                        PodcastRow(podcast: podcast)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
