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
                #warning("don'tforget spaces - concerns all project: NavigationStack {")
                NavigationStack{
                    MainView()
                        .navigationDestination(for: PodcastViewModel.PodcastRow.self) { podcast in
                            //                            let infoViewModel = InfoPdcastViewModel(selectedPodcast: podcast) - TODO: swill necessary?
                            InfoPodcastView(podcast: podcast)
                        }
                }
                
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                
                
                NavigationStack{
                    ListPodcast()
                        .navigationDestination(for: PodcastViewModel.PodcastRow.self) { podcast in
                            InfoPodcastView(podcast: podcast)
                        }
                }
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("Podcasts")
                }
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                AccountView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    #warning("don't leave empty lines whe not required - concerns all project")
    
}




