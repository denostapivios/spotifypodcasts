//
//  Constants.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 07.05.2025.
//

import SwiftUI

enum Constants {
    
    enum Icons {
        static let share = "square.and.arrow.up"
    }
    
    enum String {
        static let defaultShareURL = "https://example.com/share"
    }
    
    enum API {
        static let PodcastListBaseURL = "https://spotify23.p.rapidapi.com/podcast_episodes/"
        static let PodcastListPodcastID = "0ofXAdFIQQRsCYj9754UFx"
        static let TopListBaseURL = "https://spotify23.p.rapidapi.com/podcast_episodes/?id=0ofXAdFIQQRsCYj9754UFx&offset=11&limit=5"
    }
}
