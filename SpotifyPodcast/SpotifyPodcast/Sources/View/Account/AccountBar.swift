//
//  AccountBar.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 21.03.2025.
//

import SwiftUI

struct AccountBar: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        HStack{
            Text("Dark mode")
                .font(.body)
            
            Spacer()
            
            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
        }
        .padding(.trailing, 2)
//        .onChange(of: isDarkMode) {
//            updateAppearance()
//        }
       
    }
    #warning("no commented out code must be in dev, can only be in working branches, which are not yet opened for code review - concerns all project")
    // TODO: why commened out?
//    private func updateAppearance() {
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let window = windowScene.windows.first {
//            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
//        }
    }
//}

#warning("unnecessary empty lines")

#Preview {
    AccountBar()
}
