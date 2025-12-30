//
//  LocationViewModel.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import Foundation
import Combine

class LocationViewModel: ObservableObject {
    @Published var isTracking = false
    @Published var isPermissionDenied = false
    @Published var locationText: String = "未取得"
    @Published var errorMessage: String? = nil
    @Published var isDebugMode = false  // デバッグモード
    @Published var beaconList: [BeaconData] = []  // ビーコンリスト

    private var locationService: LocationServiceProtocol
    private let altitudeService: AltitudeServiceProtocol
    private var beaconService: BeaconServiceProtocol
    private let uuidProvider: DeviceUUIDProtocol
    private let uploadService: DataUploadServiceProtocol
    private let beaconConfig: BeaconConfigurationProtocol

    private let postURL = "http://arta.exp.mnb.ees.saitama-u.ac.jp/agp/wheelchair/upload_location_atmosphere.php"

    private var latestLocationData: LocationData?
    private var locationDataBuffer: [LocationData] = []

    init(
        locationService: LocationServiceProtocol,
        altitudeService: AltitudeServiceProtocol,
        uuidProvider: DeviceUUIDProtocol,
        uploadService: DataUploadServiceProtocol,
        beaconService: BeaconServiceProtocol,
        beaconConfig: BeaconConfigurationProtocol
    ) {
        self.locationService = locationService
        self.altitudeService = altitudeService
        self.uuidProvider = uuidProvider
        self.uploadService = uploadService
        self.beaconService = beaconService
        self.beaconConfig = beaconConfig

        self.locationService.onUpdate = { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.uploadService.buffer(data: data)

                // ビーコンなしのデータの場合のみlocationTextを更新
                if data.beaconUUID == nil {
                    self.latestLocationData = data
                    self.locationText = self.format(data: data)
                }
            }
        }

        // ビーコン更新ハンドラを設定
        self.beaconService.onBeaconsUpdate = { [weak self] beacons in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.beaconList = beacons

                // 最新の位置情報があればlocationTextも更新
                if let locationData = self.latestLocationData {
                    self.locationText = self.format(data: locationData)
                }
            }
        }

        let status = locationService.checkPermissions()
        if status == .denied {
            self.isPermissionDenied = true
        }

        // 前回セッションからの保留中アップロードをリトライ
        if let offlineQueue = (uploadService as? DataUploadService)?.offlineQueue {
            Task {
                // アプリの初期化を待つため2秒遅延
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    retryPendingUploads(offlineQueue: offlineQueue)
                }
            }
        }
    }

    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            print("[ViewModel] 📍 トラッキング開始")
            locationDataBuffer = [] // 開始時にバッファ初期化
            locationService.start()
            altitudeService.start()

            // ビーコンモニタリングを開始
            let uuids = beaconConfig.monitoredBeaconUUIDs
            print("[ViewModel] 設定されたビーコンUUID数: \(uuids.count)")
            if !uuids.isEmpty {
                beaconService.start(monitoringUUIDs: uuids)
            } else {
                print("[ViewModel] ⚠️ ビーコンUUIDが設定されていません")
            }
        } else {
            print("[ViewModel] 🛑 トラッキング停止")
            locationService.stop()
            altitudeService.stop()
            beaconService.stop()
            postBufferedDataAsCSV()
        }
    }

    private func format(data: LocationData) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        var text = """
        デバイスID: \(uuidProvider.get())
        時刻: \(formatter.string(from: data.timestamp))
        緯度: \(data.latitude)
        経度: \(data.longitude)
        高度: \(data.altitude)
        フロア: \(data.floor ?? -1)
        気圧[kPa]: \(altitudeService.currentPressure ?? 0.0)
        """

        if let beaconUUID = data.beaconUUID {
            text += """

            ビーコンUUID: \(beaconUUID)
            Major: \(data.beaconMajor ?? 0)
            Minor: \(data.beaconMinor ?? 0)
            RSSI: \(data.beaconRSSI ?? 0)
            距離: \(data.beaconProximity ?? "不明")
            精度: \(String(format: "%.2f", data.beaconAccuracy ?? 0.0))m
            """
        }

        return text
    }
    
    private func mapErrorToMessage(_ error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .timedOut:
                return "通信がタイムアウトしました。ネットワーク環境をご確認ください。"
            case .notConnectedToInternet:
                return "インターネットに接続されていません。"
            case .cannotFindHost:
                return "サーバーが見つかりませんでした。URLをご確認ください。"
            case .badURL:
                return "送信先のURLが不正です。"
            default:
                return "ネットワークエラーが発生しました。\n(\(urlError.localizedDescription))"
            }
        } else {
            return "エラーが発生しました。\n(\(error.localizedDescription))"
        }
    }
    
    private func postBufferedDataAsCSV() {
        if isDebugMode {
            // デバッグモード: CSVをコンソールに出力してバッファをクリア
            let csv = uploadService.getBufferedCSV()
            print("=== デバッグモード: CSV出力 ===")
            print(csv)
            print("=== CSV出力終了 ===")
            uploadService.clearBuffer()

            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = nil
                print("デバッグモード: データはサーバーに送信されませんでした")
            }
        } else {
            // 通常モード: サーバーに送信
            uploadService.flushBufferedData(to: postURL) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("CSV送信成功")
                    case .failure(let error):
                        self?.errorMessage = self?.mapErrorToMessage(error)
                    }
                }
            }
        }
    }

    func retryPendingUploads(offlineQueue: OfflineQueueManagerProtocol) {
        let pendingUploads = offlineQueue.getPendingUploads()

        guard !pendingUploads.isEmpty else {
            print("[ViewModel] リトライする保留中のアップロードはありません")
            return
        }

        print("[ViewModel] 🔄 \(pendingUploads.count)件の保留中アップロードをリトライ中...")

        for upload in pendingUploads {
            // 試行回数制限チェック
            guard upload.attemptCount < 10 else {
                print("[ViewModel] ⚠️ アップロード\(upload.id)は最大試行回数を超えました")
                offlineQueue.remove(uploadID: upload.id)
                continue
            }

            retryPersistedUpload(upload, offlineQueue: offlineQueue)
        }
    }

    private func retryPersistedUpload(_ upload: PersistedUpload, offlineQueue: OfflineQueueManagerProtocol) {
        guard let url = URL(string: upload.destinationURL) else {
            offlineQueue.remove(uploadID: upload.id)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/csv", forHTTPHeaderField: "Content-Type")
        request.httpBody = upload.csvData.data(using: .utf8)
        request.timeoutInterval = 30.0

        URLSession.shared.dataTask(with: request) { [weak self] _, _, error in
            if let error = error {
                print("[ViewModel] ⚠️ アップロード\(upload.id)のリトライ失敗: \(error.localizedDescription)")
                offlineQueue.incrementAttemptCount(uploadID: upload.id)
            } else {
                print("[ViewModel] ✅ アップロード\(upload.id)のリトライ成功")
                offlineQueue.remove(uploadID: upload.id)
            }
        }.resume()
    }

}
