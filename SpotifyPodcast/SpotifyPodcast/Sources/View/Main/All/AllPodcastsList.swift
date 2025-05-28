//
//  AllList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 04.05.2025.
//

import SwiftUI

struct AllPodcastsList: View {
    @ObservedObject var viewModel: PodcastViewModel
    @ObservedObject var searchViewModel: SearchListViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("All podcasts")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVStack {
                ForEach(searchViewModel.episodes, id: \.id) { podcast in
                    NavigationLink(value: podcast) {
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
        .onReceive(viewModel.$episodes) { episodes in
            searchViewModel.updatePodcast(with: episodes)
        }
    }
}

#Preview {
    AllPodcastsList(
        viewModel: PodcastViewModel(),
        searchViewModel: SearchListViewModel()
    )
}
