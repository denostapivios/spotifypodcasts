//
//  AllList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 04.05.2025.
//

import SwiftUI

struct AllPodcastsList: View {
    @Environment(AppCoordinator.self) private var coordinator
    var viewModel: PodcastViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("All podcasts")
                .font(.title2)
                .fontWeight(.bold)

            LazyVStack {
                ForEach(viewModel.filteredEpisodes, id: \.id) { podcast in
                    Button {
                        coordinator.navigateTo(place: .detail(podcast, viewModel.filteredEpisodes))
                    } label: {
                        PodcastRow(podcast: podcast)
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    }
                    .buttonStyle(.plain)
                }

                if viewModel.canLoadMore {
                    Button {
                        viewModel.loadData()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Load more")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }
}
