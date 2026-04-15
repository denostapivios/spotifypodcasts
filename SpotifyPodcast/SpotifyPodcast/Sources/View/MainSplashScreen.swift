//
//  MainSplashScreen.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import SwiftUI

struct MainSplashScreen: View {
    @Environment(AppCoordinator.self) var coordinator
    @State private var scale: CGFloat = Constants.initialScale
    
    var body: some View {
        ZStack {
            Color.customBlack
                .ignoresSafeArea()
            
            Image("iconSplash")
                .resizable()
                .frame(width: Constants.iconSize, height: Constants.iconSize)
                .scaleEffect(scale)
                .animation(.spring(response: Constants.springResponse, dampingFraction: Constants.springDamping), value: scale)
                .task {
                    scale = 1.0
                    try? await Task.sleep(for: .seconds(Constants.splashDuration))
                    coordinator.setRoot(.tabBar)
                }
        }
    }
}

private extension MainSplashScreen {
    enum Constants {
        static let iconSize: CGFloat = 200
        static let initialScale: CGFloat = 0.05
        static let springResponse: CGFloat = 0.6
        static let springDamping: CGFloat = 0.6
        static let splashDuration: Double = 1.0
    }
}

#Preview {
    MainSplashScreen()
        .environment(AppCoordinator())
}
