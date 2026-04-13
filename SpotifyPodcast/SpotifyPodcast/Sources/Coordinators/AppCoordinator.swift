//
//  AppCoordinator.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import SwiftUI
import SwiftData

@Observable
@MainActor
final class AppCoordinator {

    // MARK: - Navigation State
    var path = NavigationPath()
    var root: Place = .mainSplash
    var homePath = NavigationPath()
    var popularPath = NavigationPath()

    // MARK: - DI
    private let service: PodcastServiceProtocol
    private let searchService: SearchService

    // MARK: - Tab ViewModels
    private(set) var podcastViewModel: PodcastViewModel?
    private(set) var topListViewModel: TopListViewModel?
    private(set) var popularViewModel: PopularViewModel?
    private var modelContext: ModelContext?

    init(
        service: PodcastServiceProtocol = PodcastService(),
        searchService: SearchService = SearchService()
    ) {
        self.service = service
        self.searchService = searchService
    }

    func configure(modelContext: ModelContext) {
        guard podcastViewModel == nil else { return }
        self.modelContext = modelContext
        podcastViewModel = PodcastViewModel(
            modelContext: modelContext,
            service: service,
            searchService: searchService
        )
        topListViewModel = TopListViewModel(
            modelContext: modelContext,
            service: service
        )
        popularViewModel = PopularViewModel(
            modelContext: modelContext,
            service: service,
            searchService: searchService
        )
    }

    // MARK: - Navigation
    func navigateTo(place: Place) {
        switch place {
        case .mainSplash, .tabBar:
            path.append(place)
        case .homeDetail:
            homePath.append(place)
        case .popularDetail:
            popularPath.append(place)
        }
    }

    func setRoot(_ place: Place) {
        root = place
        path = NavigationPath()
    }
}

// MARK: - Factory Methods
extension AppCoordinator {
    
    @ViewBuilder
    func view(for place: Place) -> some View {
        switch place {
        case .mainSplash:
            MainSplashScreen()
        case .tabBar:
            AppTabView()
        case .homeDetail(let podcast):
            buildInfoPodcastView(podcast: podcast)
        case .popularDetail(let podcast):
            buildInfoPodcastView(podcast: podcast)
        }
    }

    @ViewBuilder
    func buildHomeView() -> some View {
        if let podcastViewModel, let topListViewModel {
            MainView(viewModel: podcastViewModel, topListViewModel: topListViewModel)
        }
    }

    @ViewBuilder
    func buildPopularView() -> some View {
        if let popularViewModel {
            PopularView(viewModel: popularViewModel)
        }
    }

    @ViewBuilder
    func buildInfoPodcastView(podcast: PodcastEpisode) -> some View {
        if let modelContext {
            let viewModel = PodcastViewModel(
                modelContext: modelContext,
                service: service,
                searchService: searchService
            )
            InfoPodcastView(podcast: podcast, viewModel: viewModel)
        }
    }
}
