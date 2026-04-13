//
//  AppTabView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

//  AppTabView.swift
//  ExampleProject

import SwiftUI
import SwiftData

struct AppTabView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                NavigationStack {
                    MainView(
                        viewModel: PodcastViewModel(modelContext: context),
                        topListViewModel: TopListViewModel(modelContext: context)
                    )
                    .navigationDestination(for: PodcastEpisode.self) { podcast in
                        InfoPodcastView(context: context, podcast: podcast)
                    }
                }
            }

            Tab("Popular", systemImage: "music.note.list") {
                NavigationStack {
                    PopularView(viewModel: PopularViewModel(modelContext: context))
                        .navigationDestination(for: PodcastEpisode.self) { podcast in
                            InfoPodcastView(context: context, podcast: podcast)
                        }
                }
            }

            Tab("Favorite", systemImage: "star.fill") {
                SearchView()
            }

            Tab("Account", systemImage: "person.crop.circle") {
                AccountView()
            }
        }
    }
}
