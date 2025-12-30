//
//  DataUploadService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/29.
//

import Foundation

struct RetryConfiguration {
    let maxAttempts: Int
    let initialDelay: TimeInterval
    let maxDelay: TimeInterval
    let multiplier: Double

    static let `default` = RetryConfiguration(
        maxAttempts: 3,
        initialDelay: 2.0,
        maxDelay: 16.0,
        multiplier: 2.0
    )

    func delay(for attempt: Int) -> TimeInterval {
        let exponentialDelay = initialDelay * pow(multiplier, Double(attempt - 1))
        return min(exponentialDelay, maxDelay)
    }
}

class DataUploadService: DataUploadServiceProtocol {
    private var buffer: [LocationData] = []
    var offlineQueue: OfflineQueueManagerProtocol?
    private let retryConfig = RetryConfiguration.default

    init(offlineQueue: OfflineQueueManagerProtocol? = nil) {
        self.offlineQueue = offlineQueue
    }

    func buffer(data: LocationData) {
        buffer.append(data)
    }

    func flushBufferedData(to urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !buffer.isEmpty else {
            completion(.success(())) // Nothing to send
            return
        }

        // 重要: 成功確認までバッファをクリアしない
        let csvString = convertToCSV(data: buffer)

        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        attemptUpload(
            csvString: csvString,
            url: url,
            urlString: urlString,
            attempt: 1,
            completion: completion
        )
    }

    private func attemptUpload(
        csvString: String,
        url: URL,
        urlString: String,
        attempt: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("[DataUploadService] アップロード試行 \(attempt)/\(retryConfig.maxAttempts)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/csv", forHTTPHeaderField: "Content-Type")
        request.httpBody = csvString.data(using: .utf8)
        request.timeoutInterval = 30.0

        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            guard let self = self else { return }

            if let error = error {
                if self.shouldRetry(error: error, attempt: attempt, maxAttempts: self.retryConfig.maxAttempts) {
                    let delay = self.retryConfig.delay(for: attempt)
                    print("[DataUploadService] ⚠️ アップロード失敗: \(error.localizedDescription)")
                    print("[DataUploadService] 🔄 \(delay)秒後にリトライ...")

                    DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                        self.attemptUpload(
                            csvString: csvString,
                            url: url,
                            urlString: urlString,
                            attempt: attempt + 1,
                            completion: completion
                        )
                    }
                } else {
                    // 最終失敗 - オフラインキューに保存
                    print("[DataUploadService] ❌ \(attempt)回の試行後にアップロード失敗")
                    self.offlineQueue?.enqueue(csvData: csvString, destinationURL: urlString)

                    // 重要: キューに保存後にバッファをクリア
                    self.buffer = []
                    completion(.failure(error))
                }
            } else {
                // 成功
                print("[DataUploadService] ✅ 試行\(attempt)回目でアップロード成功")

                // 重要: 成功時のみバッファをクリア
                self.buffer = []
                completion(.success(()))
            }
        }.resume()
    }

    func getBufferedCSV() -> String {
        return convertToCSV(data: buffer)
    }

    func clearBuffer() {
        buffer = []
    }

    private func convertToCSV(data: [LocationData]) -> String {
        var csv = "deviceUUID,timestamp,latitude,longitude,altitude,floor,pressure,beaconUUID,beaconMajor,beaconMinor,beaconRSSI,beaconProximity,beaconAccuracy,correlationID\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"

        for entry in data {
            let line = [
                formatter.string(from: entry.timestamp),
                entry.deviceUUID,
                "\(entry.latitude)",
                "\(entry.longitude)",
                "\(entry.altitude)",
                "\(entry.floor ?? -1)",
                "\(entry.pressure ?? 0)",
                entry.beaconUUID ?? "",
                entry.beaconMajor != nil ? "\(entry.beaconMajor!)" : "",
                entry.beaconMinor != nil ? "\(entry.beaconMinor!)" : "",
                entry.beaconRSSI != nil ? "\(entry.beaconRSSI!)" : "",
                entry.beaconProximity ?? "",
                entry.beaconAccuracy != nil ? "\(entry.beaconAccuracy!)" : "",
                entry.correlationID ?? ""
            ].joined(separator: ",")
            csv += line + "\n"
        }

        return csv
    }

    private func shouldRetry(error: Error, attempt: Int, maxAttempts: Int) -> Bool {
        guard attempt < maxAttempts else { return false }

        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut,
                 .cannotFindHost,  // DNS解決失敗 - リトライ対象
                 .cannotConnectToHost,
                 .networkConnectionLost,
                 .notConnectedToInternet,
                 .dnsLookupFailed:
                return true  // 一時的なエラー
            case .badURL,
                 .unsupportedURL:
                return false  // クライアントエラー - リトライしない
            default:
                return true  // 保守的にリトライ
            }
        }

        return true
    }
}
