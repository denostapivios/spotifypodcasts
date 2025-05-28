//
//  AppBar.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 20.03.2025.
//

import SwiftUI

struct AppBar: View {
    @Binding var searchText: String
    @State private var isSearching = false
    
    var body: some View {
        VStack {
            if isSearching {
                HStack {
                    SearchBar(
                        searchText: $searchText,
                        placeholder: "Search podcasts"
                    ) {
                        withAnimation(.easeInOut) {
                            searchText = ""
                            isSearching = false
                        }
                    }
                }
                
            } else {
                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 32)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut) {
                            isSearching = true
                        }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.trailing, 2)
            }
        }
        .animation(.default, value: isSearching)
    }
}

#Preview {
    AppBarPreviewWrapper()
}

private struct AppBarPreviewWrapper: View {
    @State private var searchText = ""
    
    var body: some View {
        AppBar(searchText: $searchText)
    }
}
