//
//  DateFormatter+MediumFormat.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 07.05.2025.
//

import Foundation

extension DateFormatter {
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

extension ISO8601DateFormatter {
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
}
