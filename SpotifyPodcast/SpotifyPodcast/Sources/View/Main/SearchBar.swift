//
//  SearchBar.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 23.05.2025.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String
    var onCancel: () -> Void
    
    public init(
        searchText: Binding<String>,
        placeholder: String = "Search",
        onCancel: @escaping () -> Void
    ) {
        self._searchText = searchText
        self.placeholder = placeholder
        self.onCancel = onCancel
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField(placeholder, text: $searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.none)
                
                Button {
                    onCancel()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .frame(height: 36)
        .padding(.trailing, 2)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
