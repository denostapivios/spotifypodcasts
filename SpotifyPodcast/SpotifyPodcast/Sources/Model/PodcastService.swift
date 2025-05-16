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
    
    private let apiKey = Bundle.main.infoDictionary?["PODCAST_API_KEY"] as? String ?? ""
    private let apiHost = Bundle.main.infoDictionary?["PODCAST_API_HOST"] as? String ?? ""
    private let requestPath = "https://spotify23.p.rapidapi.com/podcast_episodes/"
    private let podcastID = "0ofXAdFIQQRsCYj9754UFx"
    
    func fetchData(offset: Int, limit: Int) async throws -> PodcastResponse {
        guard var components = URLComponents(string: requestPath) else {
            throw PodcastServiceError(reason: "Can't make a URLComponents from \(requestPath)")
        }
        
        components.queryItems = [
            URLQueryItem(name: "id", value: podcastID),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components.url else {
            throw PodcastServiceError(reason: "Can't make a final URL with components")
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
    func fetchData(offset: Int, limit: Int) async throws -> PodcastResponse
}
