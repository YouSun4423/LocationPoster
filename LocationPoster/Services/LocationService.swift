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
    var onUpdate: ((LocationData) -> Void)?

    init(
        uuidProvider: DeviceUUIDProtocol,
        altitudeService: AltitudeServiceProtocol
    ) {
        self.uuidProvider = uuidProvider
        self.altitudeService = altitudeService
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
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }

        let data = LocationData(
            timestamp: Date(),
            deviceUUID: uuidProvider.get(),
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            altitude: loc.altitude,
            floor: loc.floor?.level,
            pressure: altitudeService.currentPressure
        )

        onUpdate?(data)
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
