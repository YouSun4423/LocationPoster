//
//  DataUploadServiceProtocol.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/29.
//

protocol DataUploadServiceProtocol {
    func buffer(data: LocationData)
    func flushBufferedData(to urlString: String, completion: @escaping (Result<Void, Error>) -> Void)
}
