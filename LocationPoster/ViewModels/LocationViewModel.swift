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

    private var locationService: LocationServiceProtocol
    private let altitudeService: AltitudeServiceProtocol
    private let networkService: NetworkServiceProtocol
    private let uuidProvider: DeviceUUIDProtocol
    private let postURL = "https://your-server.com/endpoint"

    init(
        locationService: LocationServiceProtocol,
        altitudeService: AltitudeServiceProtocol,
        networkService: NetworkServiceProtocol,
        uuidProvider: DeviceUUIDProtocol
    ) {
        self.locationService = locationService
        self.altitudeService = altitudeService
        self.networkService = networkService
        self.uuidProvider = uuidProvider

        self.locationService.onUpdate = { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.locationText = self.format(data: data)
            }
            self.networkService.post(locationData: data, to: self.postURL)
        }

        let status = locationService.checkPermissions()
        if status == .denied {
            self.isPermissionDenied = true
        }
    }

    func toggleTracking() {
        isTracking.toggle()
        if isTracking {
            locationService.start()
            altitudeService.start()
        } else {
            locationService.stop()
            altitudeService.stop()
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
}
