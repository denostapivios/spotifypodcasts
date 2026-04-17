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
    var playerEpisode: PodcastEpisode? = nil
    var root: Place = .mainSplash
    var activeTab: Tab = .home
    var homePath = NavigationPath()
    var popularPath = NavigationPath()
   
    // MARK: - Tab
    enum Tab {
        case home, popular, favorite, account
    }

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
            break
        case .detail:
            switch activeTab {
            case .home:     homePath.append(place)
            case .popular:  popularPath.append(place)
            default:        break
            }
        case .player(let episode):
            playerEpisode = episode
        }
    }

    func setRoot(_ place: Place) {
        root = place
        homePath = NavigationPath()
        popularPath = NavigationPath()
    }
    
    func dismissPlayer() {
        playerEpisode = nil
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
        case .detail(let podcast):
            buildInfoPodcastView(podcast: podcast)
        case .player:
            EmptyView()
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
