//
//  InfoPodcastView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 15.03.2025.
//

import SwiftUI
import Kingfisher
import AVKit

struct InfoPodcastView: View {
    @ObservedObject var viewModel = PodcastViewModel()
    let podcast: PodcastViewModel.PodcastRow
    
    var body: some View {
        ScrollView {
            VStack {
                switch podcast.image {
                case .remoute(let url):
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .cornerRadius(4)
                    
                case .local(let imageName):
                    Image(imageName) //інша іконка для відсутнього зображення
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                }
            }
            .padding(.bottom, 16)
            
            Text(podcast.title)
                .font(.system(size: 24))
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack (spacing:10) {
                Text("\(podcast.duration) m")
                    .font(.system(size: 14))
                Spacer()
                Text(podcast.releaseDate)
                    .font(.system(size: 14))
            }
            .padding(.bottom, 10)
            
            VStack {
                HStack(spacing:12){
                    Image(systemName: "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Image(systemName: "square.and.arrow.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                    Spacer()
                    
                    Button(action: {
                        viewModel.playAudio(from: podcast.audioPreview)
                    }) {
                        
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .foregroundColor(.white)
                            Text("Play")
                                .font(.system(size: 18))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .frame(width: 120, height: 48)
                        .background(Color.green)
                        .cornerRadius(4)
                    }
                }
            }
            .padding(.bottom, 10)
            VStack {
                Text(podcast.description)
                    .multilineTextAlignment(.leading)
            }
            .padding(.bottom, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.queryChange()
        }
        .sheet(isPresented: $viewModel.isPlayerPresented) {
            if let player = viewModel.player {
                AudioPlayerView(player: player)
            }
        }
    }
}

#Preview {
    InfoPodcastView(podcast: PodcastViewModel.PodcastRow(
        title: "Sample Podcast",
        image: .local("photo"),
        description: "This is a description of the sample podcast.",
        duration: 60,
        releaseDate: "01.01.0001",
        audioPreview: "-"
    ))
}
