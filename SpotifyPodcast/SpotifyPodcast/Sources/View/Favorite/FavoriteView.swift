//
//  FavoriteView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct FavoriteView: View {
    var viewModel: FavoriteViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                if viewModel.favorites.isEmpty {
                    emptyState
                } else {
                    FavoritePodcastsList(viewModel: viewModel)
                }
            }
            .padding(.horizontal, .spacingMedium)
            .padding(.top, .spacingMedium)
        }
        .navigationTitle("Favorite")
        .onAppear {
            viewModel.loadFavorites()
        }
    }
}

private extension FavoriteView {
    var emptyState: some View {
        VStack(spacing: .spacingMedium) {
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .frame(width: .spacingHuge, height: .spacingHuge)
                .foregroundColor(.gray.opacity(.emptyStateIconOpacity))

            Text("No favorites yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Tap the star icon on any podcast to save it here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, .emptyStateTopPadding)
    }
}

private extension CGFloat {
    static let emptyStateTopPadding: CGFloat = 80
}

private extension Double {
    static let emptyStateIconOpacity: Double = 0.4
}
