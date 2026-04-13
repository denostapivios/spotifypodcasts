//
//  AppCoordinator.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import SwiftUI

@Observable
final class AppCoordinator {
    
    var path = NavigationPath()
    var root: Place = .mainSplash
    
    func navigate(to route: Place) {
        path.append(route)
    }
    
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func backToRoot() {
        path.removeLast(path.count)
    }
    
    func setRoot(route: Place) {
        root = route
        path = NavigationPath()
    }
}

extension AppCoordinator {
    @ViewBuilder
    func view(for place: Place) -> some View {
        switch place {
        case .mainSplash:
            MainSplashScreen()
        case .tabBar:
            AppTabView()
        }
    }
}
