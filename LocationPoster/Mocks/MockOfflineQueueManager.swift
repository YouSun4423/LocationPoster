//
//  MockOfflineQueueManager.swift
//  LocationPoster
//
//  Created by Claude Code on 2025/12/30.
//

import Foundation

class MockOfflineQueueManager: OfflineQueueManagerProtocol {
    var queue: [PersistedUpload] = []

    func enqueue(csvData: String, destinationURL: String) {
        let upload = PersistedUpload(csvData: csvData, destinationURL: destinationURL)
        queue.append(upload)
    }

    func getPendingUploads() -> [PersistedUpload] {
        return queue
    }

    func remove(uploadID: UUID) {
        queue.removeAll { $0.id == uploadID }
    }

    func removeAll() {
        queue.removeAll()
    }

    func incrementAttemptCount(uploadID: UUID) {
        if let index = queue.firstIndex(where: { $0.id == uploadID }) {
            let oldUpload = queue[index]
            queue[index] = PersistedUpload(
                csvData: oldUpload.csvData,
                destinationURL: oldUpload.destinationURL,
                attemptCount: oldUpload.attemptCount + 1
            )
        }
    }
}
