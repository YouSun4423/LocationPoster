//
//  NetworkService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/27.
//
import Foundation

class NetworkService: NetworkServiceProtocol {
    func post(locationData: LocationData, to url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let requestURL = URL(string: url) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(locationData)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
}
