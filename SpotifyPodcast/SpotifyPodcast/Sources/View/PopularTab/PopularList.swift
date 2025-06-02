//
//  PopularList.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 05.05.2025.
//

import SwiftUI
import SwiftData

struct PopularList: View {
    @ObservedObject var viewModel: PopularViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Popular Podcasts")
                .font(.title2)
                .fontWeight(.bold)
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.episodes) { podcast in
                        NavigationLink(value: podcast){
                            PopularItem(podcast: podcast)
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
        .onAppear {
            viewModel.refreshData()
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CachedPodcast.self, configurations: config)
    let viewModel = PopularViewModel(modelContext: container.mainContext)
    PopularList(viewModel: viewModel)
}
