//
//  SpotifyListPodcastApp.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 28.02.2025.
//

import SwiftUI

@main
struct SpotifyPodcastApp: App {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Home", systemImage: "house") {
                    NavigationStack {
                        MainView()
                            .navigationDestination(for: PodcastEpisode.self) { podcast in
                                InfoPodcastView(podcast: podcast)
                            }
                    }
                }
                
                Tab("Popular", systemImage: "music.note.list") {
                    NavigationStack {
                        PopularView(viewModel: PodcastViewModel())
                            .navigationDestination(for: PodcastEpisode.self) { podcast in
                                InfoPodcastView(podcast: podcast)
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
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
