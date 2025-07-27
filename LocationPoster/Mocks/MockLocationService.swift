//
//  MockLocationService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import Foundation
@testable import LocationPoster

class MockLocationService: LocationServiceProtocol {
    func checkPermissions() -> LocationPermissionStatus {
            return .authorized
        }
    
    var onUpdate: ((LocationData) -> Void)?

    func start() {
        let mock = LocationData(
            timestamp: Date(),
            deviceUUID: "TEST-UUID",
            latitude: 35.0,
            longitude: 139.0,
            altitude: 50.0,
            floor: 2,
            pressure: 1013.25,
        )
        onUpdate?(mock)
    }

    func stop() {}
}
