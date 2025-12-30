//
//  OfflineQueueManagerProtocol.swift
//  LocationPoster
//
//  Created by Claude Code on 2025/12/30.
//

import Foundation

protocol OfflineQueueManagerProtocol {
    func enqueue(csvData: String, destinationURL: String)
    func getPendingUploads() -> [PersistedUpload]
    func remove(uploadID: UUID)
    func removeAll()
    func incrementAttemptCount(uploadID: UUID)
}
