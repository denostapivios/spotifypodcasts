//
//  SpotifyListPodcastTests.swift
//  SpotifyListPodcastTests
//
//  Created by Denis Ostapiv on 05.03.2025.
//

import XCTest
@testable import SpotifyListPodcast

final class SpotifyListPodcastTests: XCTestCase {
    var mockServis:MockServis!
    var sut: PodcastViewModel!
   
    
    override func setUpWithError() throws {
        mockServis = MockServis(mockedResult: PodcastResponse(data: nil))
        sut = PodcastViewModel(service: mockServis)
    }
    
    override func tearDownWithError() throws {
        sut = nil
    }
    //Якщо отримуємо запит,то рядки не пусті
    func testWhenGetQueryCouldThenRowsNoEmpty() async throws {
        // Given
        mockServis.mockedResult = .init(data: .init(podcastUnionV2: .init(episodesV2: EpisodesV2(items: [.init(uid: "", entity: .init(data: .init(id: "", name: "Test", description: "", coverArt: nil)))]))))
        // When
        sut.queryChange()
        try await Task.sleep(for: .milliseconds(1))
        // Than
        XCTAssertEqual(sut.rows.count, 1)
    }
    // Коли запит має CoverArt то рядок має картинку з інтернету
    func testWhenQueveryHasCoverArtThenRowHasRemoteImage() async throws {
        
        // Given - Умови (Дано)
        mockServis.mockedResult = .init(data: .init(podcastUnionV2: .init(episodesV2: EpisodesV2(items: [.init(uid: "", entity: .init(data: .init(id: "", name: "Test", description: "", coverArt: .init(sources: [.init(url:"https://google.com")]))))]))))
        
        // When - Коли (Коли викликаємо тести)
        sut.queryChange()
        try await Task.sleep(for: .milliseconds(1))
        
        // Then - Тоді (результат який має бути - відповідь)
        // XCTAssertEqual(sut.rows.first?.image, .remoute(URL(string: "https://google.com")))
        if case.remoute(URL(string: "https://google.com")) = sut.rows.first?.image{
            print("ok")
        } else {
            XCTFail("Remoute image expexted")
        }
    }
    // Коли запит немає CoverArt то рядок має локальну картинку
    func testWhenQueveryHasNoCoverArtThenRowHasLocalImage() async throws {
        // Given - Умови (Дано)
        mockServis.mockedResult = .init(data: .init(podcastUnionV2: .init(episodesV2: EpisodesV2(items: [.init(uid: "", entity: .init(data: .init(id: "", name: "Test", description: "", coverArt: nil)))]))))
        
        // When - Коли (Коли викликаємо тести)
        sut.queryChange()
        try await Task.sleep(for: .milliseconds(1))
        
        // Then - Тоді (результат який має бути - відповідь)
        if case.local("photo") = sut.rows.first?.image{
            print("ok")
        } else {
            XCTFail("Local image expeсted")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class MockServis:PodcastServiceProtocol {
    
    internal init(mockedResult: PodcastResponse) {
        self.mockedResult = mockedResult
    }
    
    var mockedResult:PodcastResponse
    func fetchData() async throws -> PodcastResponse {
        mockedResult
    }
}


