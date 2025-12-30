//
//  MockBeaconService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/12/30.
//

import Foundation
import CoreLocation


class MockBeaconService: BeaconServiceProtocol {
    var currentBeacons: [BeaconData] = []
    var onBeaconsUpdate: (([BeaconData]) -> Void)?

    func start(monitoringUUIDs: [UUID]) {
        // テスト用のダミービーコンデータを生成
        currentBeacons = [
            BeaconData(
                uuid: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
                major: 100,
                minor: 1,
                rssi: -65,
                proximity: .near,
                accuracy: 2.5
            ),
            BeaconData(
                uuid: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
                major: 100,
                minor: 2,
                rssi: -78,
                proximity: .far,
                accuracy: 8.3
            )
        ]
        onBeaconsUpdate?(currentBeacons)
    }

    func stop() {
        currentBeacons = []
    }
}
