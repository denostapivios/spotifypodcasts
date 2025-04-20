//
//  PopulatPodcastRow .swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 19.03.2025.
//

import SwiftUI

struct PopulatPodcastRow: View {
    @ObservedObject var viewModel = PodcastViewModel()
    var body: some View {
        VStack(alignment: .leading) {
            if viewModel.rows.count > 0 {
                Text("Popupular Podcasts")
                    .font(.title2)
                    .fontWeight(.bold)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack{
                        ForEach(viewModel.rows) { podcast in
                            NavigationLink(value: podcast){
                                PopularItem(podcast: podcast)  // Передаємо кожен подкаст в PopularItem
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(height: 185)
                }
            }
            else {
                Text("Завантаження...")
            }
        }
        .onAppear {
            viewModel.queryChange()  // Запускаємо завантаження даних
        }
        
    }
}

#Preview {
    PopulatPodcastRow()
}
