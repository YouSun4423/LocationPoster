//
//  DataUploadService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/29.
//

import Foundation

class DataUploadService: DataUploadServiceProtocol {
    private var buffer: [LocationData] = []

    func buffer(data: LocationData) {
        buffer.append(data)
    }

    func flushBufferedData(to urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !buffer.isEmpty else {
            completion(.success(())) // Nothing to send
            return
        }

        let csvString = convertToCSV(data: buffer)
        buffer = [] // Clear buffer before sending to prevent duplication

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/csv", forHTTPHeaderField: "Content-Type")
        request.httpBody = csvString.data(using: .utf8)

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }.resume()
    }

    private func convertToCSV(data: [LocationData]) -> String {
        var csv = "deviceUUID,timestamp,latitude,longitude,altitude,floor,pressure\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        for entry in data {
            let line = [
                entry.deviceUUID,
                formatter.string(from: entry.timestamp),
                "\(entry.latitude)",
                "\(entry.longitude)",
                "\(entry.altitude)",
                "\(entry.floor ?? -1)",
                "\(entry.pressure ?? 0)"
            ].joined(separator: ",")
            csv += line + "\n"
        }

        return csv
    }
}
