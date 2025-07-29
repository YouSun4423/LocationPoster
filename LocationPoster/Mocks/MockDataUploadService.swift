//
//  MockDataUploadService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/29.
//

class MockUploadService: DataUploadServiceProtocol {
    func buffer(data: LocationData) {
        print("Mock buffer called with data: \(data)")
    }

    func flushBufferedData(to urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Mock flush to: \(urlString)")
        completion(.success(()))
    }
}
