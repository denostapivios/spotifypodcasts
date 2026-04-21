//
//  SpotifyListPodcastSwiftTests.swift
//  SpotifyListPodcastSwiftTests
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import Testing
@testable import SpotifyPodcast

// MARK: - SearchService

@Suite("SearchService")
struct SearchServiceTests {

    let service = SearchService()

    let episodes = [
        PodcastEpisode.mock(id: "1", title: "Swift Concurrency Deep Dive"),
        PodcastEpisode.mock(id: "2", title: "SwiftUI Tips and Tricks"),
        PodcastEpisode.mock(id: "3", title: "Introduction to Kotlin"),
    ]

    @Test("Empty query returns all episodes")
    func emptyQueryReturnsAll() {
        let result = service.filter(episodes, by: "")
        #expect(result.count == 3)
    }

    @Test("Search is case insensitive")
    func searchIsCaseInsensitive() {
        let result = service.filter(episodes, by: "swift")
        #expect(result.count == 2)
        #expect(result.map(\.id) == ["1", "2"])
    }

    @Test("No match returns empty array")
    func noMatchReturnsEmpty() {
        let result = service.filter(episodes, by: "Python")
        #expect(result.isEmpty)
    }

    @Test("Partial word match works")
    func partialMatchWorks() {
        let result = service.filter(episodes, by: "Kotlin")
        #expect(result.count == 1)
        #expect(result.first?.id == "3")
    }
}

// MARK: - PodcastEpisode

@Suite("PodcastEpisode")
struct PodcastEpisodeTests {

    @Test("Duration: milliseconds are correctly converted to minutes")
    func durationConversion() {
        let episode = PodcastEpisode.mock(durationMillis: 3_720_000) // 62 minutes
        #expect(episode.duration == "62 m")
    }

    @Test("Duration: 0 milliseconds returns 0 minutes")
    func zeroDuration() {
        let episode = PodcastEpisode.mock(durationMillis: 0)
        #expect(episode.duration == "0 m")
    }

    @Test("Duration: less than one minute returns 0 minutes")
    func lessThanOneMinute() {
        let episode = PodcastEpisode.mock(durationMillis: 59_999)
        #expect(episode.duration == "0 m")
    }

    @Test("mock() creates episode with correct id")
    func mockHasCorrectId() {
        let episode = PodcastEpisode.mock(id: "test-123")
        #expect(episode.id == "test-123")
    }

    @Test("placeholder() creates correct number of episodes")
    func placeholderCount() {
        let episodes = PodcastEpisode.placeholder(count: 7)
        #expect(episodes.count == 7)
    }

    @Test("placeholder() all episodes have unique ids")
    func placeholderUniqueIds() {
        let episodes = PodcastEpisode.placeholder(count: 5)
        let uniqueIds = Set(episodes.map(\.id))
        #expect(uniqueIds.count == 5)
    }
}
