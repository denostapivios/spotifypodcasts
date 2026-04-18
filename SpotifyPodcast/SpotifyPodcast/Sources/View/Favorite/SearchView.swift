//
//  SearchView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Search", text: $searchText)
                    .padding(10)
                    .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.secondary, lineWidth: 1))
                    .padding(.horizontal)
                    .overlay(
                        HStack {
                            Spacer()
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(5)
                                }
                            }
                        }
                    )
                
                Spacer()
                
            }
            .navigationTitle("Search")
        }
    }
}
