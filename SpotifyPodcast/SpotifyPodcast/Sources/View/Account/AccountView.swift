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
                
                // TODO: for this section, create an enum with each case representing a row, make foreach, iterating the cases, with simple text as navigation destination. Have row titles as raw values for your enum cases
                Section {
                    NavigationLink(destination: Label("Downloaded podcasts", systemImage: "square.and.arrow.down.fill")) {
                        Text("Downloaded")
                    }
                    NavigationLink(destination: Label("Favorite podcasts", systemImage: "star.fill")) {
                        Text("Favorite")
                    }
                    NavigationLink(destination: Label("All settings", systemImage: "gearshape.fill")) {
                        Text("Settings")
                    }
                    NavigationLink(destination: Label("Info App", systemImage: "info.circle.fill")) {
                        Text("Info")
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
