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
    
    private let apiKey: String
    private let apiHost: String
    
    init(
        apiKey: String = Bundle.main.infoDictionary?["PODCAST_API_KEY"] as? String ?? "",
        apiHost: String = Bundle.main.infoDictionary?["PODCAST_API_HOST"] as? String ?? ""
    ) {
        self.apiKey = apiKey
        self.apiHost = apiHost
    }
    
    func fetchData(from baseURL: String, podcastID: String, offset: Int, limit: Int) async throws -> PodcastResponse {
        guard var components = URLComponents(string: baseURL) else {
            throw PodcastServiceError(reason: "Can't make a URLComponents from \(baseURL)")
        }
        components.queryItems = [
            URLQueryItem(name: "id", value: podcastID),
            URLQueryItem(name: "offset", value: "\(offset)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        guard let url = components.url else {
            throw PodcastServiceError(reason: "Can't make a final URL with components")
        }
        return try await performRequest(url: url)
    }
    
    private func performRequest(url: URL) async throws -> PodcastResponse {
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
    func fetchData(from baseURL: String, podcastID: String, offset: Int, limit: Int) async throws -> PodcastResponse
}
