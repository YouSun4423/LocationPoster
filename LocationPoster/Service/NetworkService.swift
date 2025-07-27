//
//  NetworkService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/27.
//
import Foundation

class NetworkService {
    func post(locationData: LocationData, to url: String) {
        guard let endpoint = URL(string: url) else { return }
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let json = try JSONEncoder().encode(locationData)
            request.httpBody = json

            URLSession.shared.dataTask(with: request).resume()
        } catch {
            print("POSTエラー: \(error)")
        }
    }
}
