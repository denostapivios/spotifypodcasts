//
//  DebounceManager.swift
//  SpotifyPodcast
//
//  Created by Denis Ostapiv on 26.05.2025.
//

import Foundation

class DebounceManager {
    private var workItem: DispatchWorkItem?
    
    func debounce(delay: TimeInterval = 0.5, action: @escaping () -> Void) {
        print("🕒 debounce викликано")
        workItem?.cancel()
        
        let task = DispatchWorkItem {
                print("⏱ debounce виконано через \(delay) сек")
                action()
            }
        workItem = task
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
    }
}
