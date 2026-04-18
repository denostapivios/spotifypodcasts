//
//  AccountView.swift
//  SpotifyListPodcast
//
//  Created by Denis Ostapiv on 18.03.2025.
//

import SwiftUI

struct AccountView: View {
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: .spacingMedium) {
                    profileCard
                    settingsCard
                    infoCard
                    versionText
                }
                .padding(.spacingMedium)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Account")
        }
    }
}

private extension AccountView {
    var profileCard: some View {
        HStack(spacing: .spacingMedium) {
            Image(.account)
                .resizable()
                .frame(width: .imageSmall, height: .imageSmall)
                .foregroundColor(.gray)
                .clipShape(Circle())
            Text("Denis Ostapiv (iOS Developer)")
                .font(.headline)
            Spacer()
        }
        .padding(.spacingMedium)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(.radiusMedium)
    }

    var settingsCard: some View {
        AccountBar()
            .padding(.spacingMedium)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(.radiusMedium)
    }

    var infoCard: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            Text("Info")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("An iOS application for browsing, listening to, and saving podcasts using the Spotify API. Built with SwiftUI and structured using MVVM-C (Model-View-ViewModel-Coordinator) architecture. The project implements Dependency Injection (DI) to ensure a modular, testable, and scalable codebase, featuring caching, pagination, and audio playback.")
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.spacingMedium)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(.radiusMedium)
    }

    var versionText: some View {
        Text("Version 0.0.1")
            .foregroundStyle(.gray)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    AccountView()
}
