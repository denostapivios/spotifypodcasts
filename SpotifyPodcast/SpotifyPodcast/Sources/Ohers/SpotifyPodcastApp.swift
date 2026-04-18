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
            CoordinatorView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [CachedPodcast.self, FavoritePodcast.self])
    }
}
