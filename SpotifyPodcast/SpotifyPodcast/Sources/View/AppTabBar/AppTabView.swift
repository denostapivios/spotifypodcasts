//
//  AppTabView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import SwiftUI
import SwiftData

struct AppTabView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator

        TabView(selection: $coordinator.activeTab) {
            Tab("Home", systemImage: "house", value: .home) {
                NavigationStack(path: $coordinator.homePath) {
                    coordinator.buildHomeView()
                        .navigationDestination(for: Place.self) { place in
                            coordinator.view(for: place)
                        }
                }
            }

            Tab("Popular", systemImage: "music.note.list", value: .popular) {
                NavigationStack(path: $coordinator.popularPath) {
                    coordinator.buildPopularView()
                        .navigationDestination(for: Place.self) { place in
                            coordinator.view(for: place)
                        }
                }
            }

            Tab("Favorite", systemImage: "star.fill", value: .favorite) {
                SearchView()
            }

            Tab("Account", systemImage: "person.crop.circle", value: .account) {
                AccountView()
            }
        }
        .task {
            coordinator.configure(modelContext: context)
        }
        .sheet(item: $coordinator.playerEpisode) { episode in
            coordinator.buildPlayerView(episode: episode)
                .presentationDetents([.large])
        }
    }
}
