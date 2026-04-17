//
//  Place.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 13.04.2026.
//

import SwiftUI

enum Place: Hashable {
    case mainSplash
    case tabBar
    case detail(PodcastEpisode, [PodcastEpisode])
    case player(PodcastEpisode, [PodcastEpisode])
}
