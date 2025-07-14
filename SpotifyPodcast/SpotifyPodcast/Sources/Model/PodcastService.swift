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
    
    func fetchData(
        from baseURL: String,
        podcastID: String,
        offset: Int,
        limit: Int
    ) async throws -> PodcastResponse {
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
        
        // Simulation of 500 if a launch argument is provided
        if ProcessInfo.processInfo.arguments.contains("SIMULATE_500") {
            throw PodcastServiceError(reason: "Simulated Internal Server Error (500)")
        }
        
        var request = URLRequest(url: url)
        // Send a network request
        
        request.setValue(apiKey, forHTTPHeaderField: "x-rapidapi-key")
        request.setValue(apiHost, forHTTPHeaderField: "x-rapidapi-host")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Headers and API keys
        
        let (data, response) = try await URLSession.shared.data(for: request)
        // Received a response
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PodcastServiceError(reason: "Invalid response")
        }
        
        if httpResponse.statusCode == 500 {
            throw PodcastServiceError(reason: "Internal Server Error (500)")
        }
        
        let decodedResponse = try JSONDecoder().decode(PodcastResponse.self, from: data)
        // Parsed JSON data into a model
        
        return decodedResponse
    }
    
    func loadFallbackFromFile() -> PodcastResponse? {
        guard let url = Bundle.main.url(forResource: "fallback", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not be found or read fallback.json")
            return nil
        }
        do {
            let decoded = try JSONDecoder().decode(PodcastResponse.self, from: data)
            return decoded
        } catch {
            print("Decoding error fallback.json: \(error)")
            return nil
        }
    }
}

protocol PodcastServiceProtocol {
    func fetchData(
        from baseURL: String,
        podcastID: String,
        offset: Int,
        limit: Int
    ) async throws -> PodcastResponse
    
    func loadFallbackFromFile() -> PodcastResponse?
}
