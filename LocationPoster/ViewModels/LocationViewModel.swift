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

    private var locationService: LocationServiceProtocol
    private let altitudeService: AltitudeServiceProtocol
    private let uuidProvider: DeviceUUIDProtocol
    private let uploadService: DataUploadServiceProtocol
    
    private let postURL = "http://arta.exp.mnb.ees.saitama-u.ac.jp/agp/wheelchair/upload_location_atmosphere.php"


    private var locationDataBuffer: [LocationData] = []

    init(
        locationService: LocationServiceProtocol,
        altitudeService: AltitudeServiceProtocol,
        uuidProvider: DeviceUUIDProtocol,
        uploadService: DataUploadServiceProtocol
    ) {
        self.locationService = locationService
        self.altitudeService = altitudeService
        self.uuidProvider = uuidProvider
        self.uploadService = uploadService

        self.locationService.onUpdate = { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.uploadService.buffer(data: data)
                self.locationText = self.format(data: data)
                self.locationText = self.format(data: data)
            }
        }

        let status = locationService.checkPermissions()
        if status == .denied {
            self.isPermissionDenied = true
        }
    }

    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            locationDataBuffer = [] // 開始時にバッファ初期化
            locationService.start()
            altitudeService.start()
        } else {
            locationService.stop()
            altitudeService.stop()
            postBufferedDataAsCSV()
        }
    }

    private func format(data: LocationData) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return """
        デバイスID: \(uuidProvider.get())
        時刻: \(formatter.string(from: data.timestamp))
        緯度: \(data.latitude)
        経度: \(data.longitude)
        高度: \(data.altitude)
        フロア: \(data.floor ?? -1)
        気圧[kPa]: \(altitudeService.currentPressure ?? 0.0)
        """
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
