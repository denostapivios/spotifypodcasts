//
//  PodcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 04.03.2025.
//

import Foundation
// Service for sharing a podcast list
class PodcastService: ObservableObject, PodcastServiceProtocol {
    
    struct PodcastServiceError: Error {
        let reason: String
    }
    
    let requestPath = "https://spotify23.p.rapidapi.com/podcast_episodes/?id=0ofXAdFIQQRsCYj9754UFx&offset=0&limit=50"
    private let apiKey = "1578655d4emsh8eeb7f79d494a91p187668jsn99278f89eb29"
    private let apiHost = "spotify23.p.rapidapi.com"
    
    func fetchData() async throws -> PodcastResponse {
        guard let url = URL(string: requestPath) else {
            throw PodcastServiceError(reason: "Не можу зробити URL від \(requestPath)")
        }
        
        var request = URLRequest(url: url)
        // Send a network request
        
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Headers and API keys
        
        let response = try await URLSession.shared.data(for: request)
        // Received a response
        
        let data = response.0
        
        let decodedResponse = try JSONDecoder().decode(PodcastResponse.self, from: data)
        // Parsed JSON data into a model
        
        return decodedResponse
    }
}

protocol PodcastServiceProtocol {
    func fetchData() async throws -> PodcastResponse
}
