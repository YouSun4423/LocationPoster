//
//  BeaconService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/12/30.
//

import Foundation
import CoreLocation


class BeaconService: NSObject, BeaconServiceProtocol, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var monitoredRegions: [CLBeaconRegion] = []
    private(set) var currentBeacons: [BeaconData] = []
    var onBeaconsUpdate: (([BeaconData]) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func start(monitoringUUIDs: [UUID]) {
        // 既存の監視をクリア
        stop()

        print("[BeaconService] ビーコンモニタリング開始")
        print("[BeaconService] 監視対象UUID数: \(monitoringUUIDs.count)")

        // 各UUIDのregionを作成
        for uuid in monitoringUUIDs {
            print("[BeaconService] UUID登録: \(uuid.uuidString)")
            let region = CLBeaconRegion(
                uuid: uuid,
                identifier: "BeaconRegion-\(uuid.uuidString)"
            )
            region.notifyEntryStateOnDisplay = true
            monitoredRegions.append(region)

            // モニタリングとrangingを開始
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid))
        }
    }

    func stop() {
        print("[BeaconService] ビーコンモニタリング停止")
        for region in monitoredRegions {
            locationManager.stopMonitoring(for: region)
            if let uuid = (region as? CLBeaconRegion)?.uuid {
                locationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid))
            }
        }
        monitoredRegions = []
        currentBeacons = []
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(
        _ manager: CLLocationManager,
        didRange beacons: [CLBeacon],
        satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
        print("[BeaconService] ビーコンranging更新: \(beacons.count)個検出")

        // CLBeaconをBeaconDataに変換
        let beaconData = beacons.map { beacon in
            print("[BeaconService] - UUID: \(beacon.uuid.uuidString), Major: \(beacon.major), Minor: \(beacon.minor), RSSI: \(beacon.rssi), Proximity: \(beacon.proximity.rawValue)")
            return BeaconData(
                uuid: beacon.uuid.uuidString,
                major: beacon.major.intValue,
                minor: beacon.minor.intValue,
                rssi: beacon.rssi,
                proximity: beacon.proximity,
                accuracy: beacon.accuracy
            )
        }

        currentBeacons = beaconData
        onBeaconsUpdate?(beaconData)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint,
        error: Error
    ) {
        print("[BeaconService] ❌ Beacon ranging失敗: \(error.localizedDescription)")
        currentBeacons = []
    }
}
