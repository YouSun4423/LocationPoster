//
//  LocationService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/27.
//
import CoreLocation
import CoreMotion


class LocationService: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let altimeter = CMAltimeter()
    var onUpdate: ((LocationData) -> Void)?

    private var currentPressure: Double?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }

    func start() {
        locationManager.startUpdatingLocation()
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                self?.currentPressure = data?.pressure.doubleValue
            }
        }
    }

    func stop() {
        locationManager.stopUpdatingLocation()
        altimeter.stopRelativeAltitudeUpdates()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let data = LocationData(
            timestamp: Date(),
            deviceUUID: DeviceUUIDService.get(),
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            altitude: loc.altitude,
            floor: loc.floor?.level,
            pressure: currentPressure,
        )
        onUpdate?(data)
    }
}
