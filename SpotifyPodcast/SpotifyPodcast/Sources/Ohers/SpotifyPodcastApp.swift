//
//  SpotifyListPodcastApp.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 28.02.2025.
//

import SwiftUI
import SwiftData

@main
struct SpotifyPodcastApp: App {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            AppContent()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: CachedPodcast.self)
    }
}


struct AppContent: View {
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
                    PopularView(context: context)
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
