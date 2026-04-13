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
        TabView {
            Tab("Home", systemImage: "house") {
                coordinator.buildHomeView()
            }

            Tab("Popular", systemImage: "music.note.list") {
                coordinator.buildPopularView()
            }

            Tab("Favorite", systemImage: "star.fill") {
                SearchView()
            }

            Tab("Account", systemImage: "person.crop.circle") {
                AccountView()
            }
        }
        .onAppear {
            coordinator.configure(modelContext: context)
        }
    }
}
