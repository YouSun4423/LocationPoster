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
    
    func buffer(data: LocationData) {
        print("Mock buffer called with data: \(data)")
        bufferedData.append(data)
    }

    func flushBufferedData(to urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Mock flush to: \(urlString)")
        completion(.success(()))
    }
}
