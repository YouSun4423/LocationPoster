//
//  LocationService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/27.
//
import CoreLocation
import CoreMotion


class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private let uuidProvider: DeviceUUIDProtocol
    private let altitudeService: AltitudeServiceProtocol
    private let beaconService: BeaconServiceProtocol
    var onUpdate: ((LocationData) -> Void)?

    init(
        uuidProvider: DeviceUUIDProtocol,
        altitudeService: AltitudeServiceProtocol,
        beaconService: BeaconServiceProtocol
    ) {
        self.uuidProvider = uuidProvider
        self.altitudeService = altitudeService
        self.beaconService = beaconService
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
    }

    func start() {
        locationManager.startUpdatingLocation()
        altitudeService.start()
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        altitudeService.stop()
        beaconService.stop()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        let beacons = beaconService.currentBeacons
        print("[LocationService] 位置情報更新 - ビーコン数: \(beacons.count)")

        if beacons.isEmpty {
            // ビーコンが検出されていない場合: ビーコンフィールドがnilの1つのLocationDataを生成
            print("[LocationService] ビーコンなし - 通常のLocationData生成")
            let data = LocationData(
                timestamp: Date(),
                deviceUUID: uuidProvider.get(),
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                altitude: loc.altitude,
                floor: loc.floor?.level,
                pressure: altitudeService.currentPressure,
                beaconUUID: nil,
                beaconMajor: nil,
                beaconMinor: nil,
                beaconRSSI: nil,
                beaconProximity: nil,
                beaconAccuracy: nil,
                correlationID: nil
            )
            onUpdate?(data)
        } else {
            // 複数のビーコンが検出された場合: 各ビーコンごとにLocationDataを生成
            let correlationID = UUID().uuidString
            let timestamp = Date()
            print("[LocationService] ビーコン検出 - \(beacons.count)個のLocationData生成 (CorrelationID: \(correlationID))")

            for beacon in beacons {
                let data = LocationData(
                    timestamp: timestamp,
                    deviceUUID: uuidProvider.get(),
                    latitude: loc.coordinate.latitude,
                    longitude: loc.coordinate.longitude,
                    altitude: loc.altitude,
                    floor: loc.floor?.level,
                    pressure: altitudeService.currentPressure,
                    beaconUUID: beacon.uuid,
                    beaconMajor: beacon.major,
                    beaconMinor: beacon.minor,
                    beaconRSSI: beacon.rssi,
                    beaconProximity: beacon.proximityString,
                    beaconAccuracy: beacon.accuracy,
                    correlationID: correlationID
                )
                print("[LocationService] - ビーコン: UUID=\(beacon.uuid), Major=\(beacon.major), Minor=\(beacon.minor)")
                onUpdate?(data)
            }
        }
    }

    func checkPermissions() -> LocationPermissionStatus {
        let locationStatus = locationManager.authorizationStatus
        let motionDenied = CMMotionActivityManager.authorizationStatus() == .denied

        if locationStatus == .denied || motionDenied {
            return .denied
        } else if locationStatus == .notDetermined {
            return .notDetermined
        } else {
            return .authorized
        }
    }
}


enum LocationPermissionStatus {
    case authorized
    case denied
    case notDetermined
}
