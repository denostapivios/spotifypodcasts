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
    var playerPlaylist: [PodcastEpisode] = []
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
    private let audioService: any AudioPlayerServiceProtocol

    // MARK: - Tab ViewModels
    private(set) var podcastViewModel: PodcastViewModel?
    private(set) var topListViewModel: TopListViewModel?
    private(set) var popularViewModel: PopularViewModel?
    private var modelContext: ModelContext?

    init(
        service: PodcastServiceProtocol = PodcastService(),
        searchService: SearchService = SearchService(),
        audioService: (any AudioPlayerServiceProtocol)? = nil
    ) {
        self.service = service
        self.searchService = searchService
        self.audioService = audioService ?? AudioPlayerService()
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
        case .detail(_, _):
            switch activeTab {
            case .home:     homePath.append(place)
            case .popular:  popularPath.append(place)
            default:        break
            }
        case .player(let episode, let playlist):
            playerEpisode = episode
            playerPlaylist = playlist
        }
    }

    func setRoot(_ place: Place) {
        root = place
        homePath = NavigationPath()
        popularPath = NavigationPath()
    }
    
    func dismissPlayer() {
        audioService.stop()
        playerEpisode = nil
        playerPlaylist = []
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
        case .detail(let podcast, let episodes):
            buildInfoPodcastView(podcast: podcast, episodes: episodes)
        case .player(_, _):
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
    func buildPlayerView(episode: PodcastEpisode) -> some View {
        let viewModel = PlayerViewModel(episode: episode, playlist: playerPlaylist, audioService: audioService)
        PlayerView(viewModel: viewModel)
    }

    @ViewBuilder
    func buildInfoPodcastView(podcast: PodcastEpisode, episodes: [PodcastEpisode]) -> some View {
        if let modelContext {
            let viewModel = PodcastViewModel(
                modelContext: modelContext,
                service: service,
                searchService: searchService
            )
            InfoPodcastView(podcast: podcast, episodes: episodes, viewModel: viewModel)
        }
    }
}
