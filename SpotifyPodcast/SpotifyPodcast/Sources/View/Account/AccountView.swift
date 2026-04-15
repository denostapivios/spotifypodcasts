//
//  AccountView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct AccountView: View {
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: Text("Log in to your account")) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        VStack(alignment: .leading) {
                            Text("Log in")
                                .font(.headline)
                        }
                    }
                }
                
                Section {
                    AccountBar()
                }
                
                Section {
                    LabeledContent {
               
                    } label: {
                        Text("Info")
                        Text("An iOS application for browsing, listening to, and saving podcasts using the Spotify API. Built with SwiftUI and structured using MVVM-C (Model-View-ViewModel-Coordinator) architecture. The project implements Dependency Injection (DI) to ensure a modular, testable, and scalable codebase, featuring caching, pagination, and audio playback.")
                            .font(.caption)
                    }
                }
                
                Text("Version 0.0.1")
                    .foregroundStyle(.gray)
            }
            .navigationTitle("Account")
        }
    }
}

#Preview {
    AccountView()
}
