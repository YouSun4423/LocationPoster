//
//  PersistedUpload.swift
//  LocationPoster
//
//  Created by Claude Code on 2025/12/30.
//

import Foundation

struct PersistedUpload: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let csvData: String
    let destinationURL: String
    let attemptCount: Int

    init(csvData: String, destinationURL: String, attemptCount: Int = 0) {
        self.id = UUID()
        self.timestamp = Date()
        self.csvData = csvData
        self.destinationURL = destinationURL
        self.attemptCount = attemptCount
    }
}
