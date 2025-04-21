//
//  InfoPdcastViewModel.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 16.03.2025.
//

import Foundation

class InfoPdcastViewModel: ObservableObject {
   
    internal init(
//        selectedPodcast: PodcastViewModel.PodcastRow,
        service: any PodcastServiceProtocol = PodcastService()
    ) {
//        self.selectedPodcast = selectedPodcast
        self.service = service
    }
    
    
//    init (podcast: PodcastViewModel){
//        self.service = podcast.service
//        self.rowsInfo = podcast.rows
//    }

//    internal init(service: any PodcastServiceProtocol = PodcastService()) {
//        self.service = service
//        self.podcastResult = podcastResult
//        self.rowsInfo = rowsInfo
//    }

    enum PodcastImage: Hashable  {
        case remoute (URL)
        case local (String)
    }

    struct PodcastRowInfo: Identifiable, Hashable {
        let id = UUID()
        let title: String
        let image: PodcastImage
        let description: String
        let duration: Int
//        let data: Data
    }

//    let selectedPodcast:PodcastViewModel.PodcastRow
    
    let service:PodcastServiceProtocol
    @Published var podcastResult: PodcastResponse? {
        willSet{
            objectWillChange.send()
        }
    }

    @Published var rowsInfo:PodcastRowInfo?

    func procesResult(dataObject:PodcastResponse) -> [PodcastRowInfo] {

        dataObject.data?.podcastUnionV2?.episodesV2?.items?.map { episodData in
            let image:PodcastImage
            if
                let imageString = episodData.entity?.data?.coverArt?.sources?.first?.url,
                let url = URL(string: imageString){

                image = .remoute(url)

            } else {
                //                image = Double.random(in: 0..<1) > 0.5 ? .local("photo"):.local("photo1")
                image = .local("photo")
            }

            let durationMilliseconds = episodData.entity?.data?.duration?.totalMilliseconds ?? 0
            let durationMinutes = durationMilliseconds / 60000

            return PodcastRowInfo(
                title: episodData.entity?.data?.name ?? "-",
                image: image,
                description: episodData.entity?.data?.description ?? "-",
                duration: durationMinutes
//                data: episodData.entity?.data?.data?.isoString ?? Data()
            )
        }
        ?? []
    }

    func queryChange() {
        Task {
            do {
               
                let result = try await service.fetchData()
                let infoRows = procesResult(dataObject: result)
                await MainActor.run {
                    podcastResult = result

//                    self.rowsInfo = infoRows
                }
            } catch {
                print("Помилка завантаження: \(error.localizedDescription)")
            }
        }
    }

}

