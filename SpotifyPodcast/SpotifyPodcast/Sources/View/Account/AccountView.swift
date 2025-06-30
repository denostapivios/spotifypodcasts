//
//  AccountView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

enum SectionRow: String, CaseIterable {
    case downloaded = "Downloaded"
    case favorite = "Favorite"
    case settings = "Settings"
    case info = "Info"
}

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
                    ForEach(SectionRow.allCases, id: \.self) { row in
                        NavigationLink(destination: Text(row.rawValue)) {
                            Text(row.rawValue)
                        }
                    }
                }
                
                Text("Version 0.0.1")
                    .foregroundStyle(.gray)
            }
            .navigationTitle("Account")
        }
        
    }
}
