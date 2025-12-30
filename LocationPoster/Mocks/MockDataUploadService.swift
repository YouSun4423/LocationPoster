//
//  MockDataUploadService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/29.
//
@testable import LocationPoster
import Foundation

class MockDataUploadService: DataUploadServiceProtocol {
    var bufferedData: [LocationData] = []
    var offlineQueue: OfflineQueueManagerProtocol?

    init(offlineQueue: OfflineQueueManagerProtocol? = nil) {
        self.offlineQueue = offlineQueue
    }

    func buffer(data: LocationData) {
        print("Mock buffer called with data: \(data)")
        bufferedData.append(data)
    }

    func flushBufferedData(to urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Mock flush to: \(urlString)")
        completion(.success(()))
    }

    func getBufferedCSV() -> String {
        return "Mock CSV data"
    }

    func clearBuffer() {
        bufferedData = []
    }
}
