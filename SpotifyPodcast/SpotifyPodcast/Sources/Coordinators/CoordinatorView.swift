//
//  CoordinatorView.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import SwiftUI

struct CoordinatorView: View {
    @State private var coordinator = AppCoordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.view(for: coordinator.root)
                .navigationDestination(for: Place.self) { place in
                    coordinator.view(for: place)
                }
        }
        .environment(coordinator)
    }
}
