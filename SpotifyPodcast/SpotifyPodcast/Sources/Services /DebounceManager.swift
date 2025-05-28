//
//  DebounceManager.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 26.05.2025.
//

import Foundation

actor DebounceManager {
    private var workItem: Task<Void,Never>?
    
    func debounce(delay: TimeInterval = 5.0, action: @escaping () async -> Void) {
        workItem?.cancel()
        
        workItem = Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            await action()
        }
    }
}
