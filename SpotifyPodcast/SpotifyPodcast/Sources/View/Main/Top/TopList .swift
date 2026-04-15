//
//  PopulatPodcastRow .swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI

struct TopList: View {
    @Environment(AppCoordinator.self) private var coordinator
    var viewModel: TopListViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Top Podcasts")
                .font(.title2)
                .fontWeight(.bold)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(viewModel.isLoading ? PodcastEpisode.placeholder() : viewModel.episodes) { podcast in
                        Button {
                            coordinator.navigateTo(place: .homeDetail(podcast))
                        } label: {
                            TopItem(podcast: podcast)
                                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                .animation(.default, value: viewModel.isLoading)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .task {
            await viewModel.loadIfNeeded()
        }
    }
}
