//
//  InfoPodcastView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 15.03.2025.
//

import SwiftUI
import Kingfisher
import AVKit
import SwiftData

struct InfoPodcastView: View {
    @StateObject var viewModel: PodcastViewModel
    let podcast: PodcastEpisode
    
    init(context: ModelContext, podcast: PodcastEpisode) {
        _viewModel = StateObject(wrappedValue: PodcastViewModel(modelContext: context))
        self.podcast = podcast
    }
    
    var body: some View {
        ScrollView {
            VStack {
                image
            }
            .padding(.bottom, 16)
            
            title
            
            HStack (spacing:10) {
                duration
                Spacer()
                releaseDate
            }
            .padding(.bottom, 10)
            
            VStack {
                HStack(spacing:12) {
                    favoriteIcon
                    downloadedIcon
                    shareIcon
                    moreIcon
                    
                    Spacer()
                    
                    Button {
                        if let url = podcast.audioPreview {
                            viewModel.playAudio(from: url)
                        }
                    } label: {
                        HStack {
                            buttonImage
                            buttonText
                        }
                        .padding()
                        .frame(width: 120, height: 48)
                        .background(Color.green)
                        .cornerRadius(4)
                    }
                }
            }
            .padding(.bottom, 10)
            
            description
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.refreshData()
        }
        .sheet(isPresented: $viewModel.isPlayerPresented) {
            if let player = viewModel.player {
                AudioPlayerView(player: player)
            }
        }
    }
}

private extension InfoPodcastView {
    
    var title: some View {
        Text(podcast.title)
            .font(.system(size: 24))
            .fontWeight(.bold)
            .multilineTextAlignment(.leading)
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var duration: some View {
        Text(podcast.duration)
            .font(.system(size: 14))
    }
    
    var releaseDate: some View {
        Text(podcast.releaseDate)
            .font(.system(size: 14))
    }
    
    var favoriteIcon: some View {
        Image(systemName: "star")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
    
    var downloadedIcon: some View {
        Image(systemName: "square.and.arrow.down")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
    
    var shareIcon: some View {
        ShareLink(item: podcast.sharingInfo ?? Constants.String.defaultShareURL) {
            Image(systemName: Constants.Icons.share)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }
    
    var moreIcon: some View {
        Image(systemName: "ellipsis")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
    
    var description: some View {
        Text(podcast.description)
            .multilineTextAlignment(.leading)
    }
    
    var buttonImage: some View {
        Image(systemName: "play.circle.fill")
            .foregroundColor(.white)
    }
    
    var buttonText: some View {
        Text("Play")
            .font(.system(size: 18))
            .fontWeight(.bold)
            .foregroundColor(.white)
    }
    
    var image: some View {
        switch podcast.image {
        case .remote(let url):
            return AnyView(
                KFImage(url)
                    .resizable()
                    .placeholder {
                        ProgressView()
                    }
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(4)
            )
        case .placeholder(let imageName):
            return AnyView(
                Image(imageName) //інша іконка для відсутнього зображення
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(4)
            )
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CachedPodcast.self, configurations: config)
    return InfoPodcastView(context: container.mainContext, podcast: PodcastEpisode.mock())
}
