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
        coordinator.view(for: coordinator.root)
            .environment(coordinator)
    }
}
