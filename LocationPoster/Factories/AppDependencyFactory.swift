//
//  AppDependencyFactory.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import Foundation

struct AppDependencyFactory {
    static func makeViewModel() -> LocationViewModel {
        let uuidProvider = DeviceUUIDService()
        let altitudeService = AltitudeService()
        let beaconConfig = BeaconConfigurationService()
        let beaconService = BeaconService()
        let locationService = LocationService(
            uuidProvider: uuidProvider,
            altitudeService: altitudeService,
            beaconService: beaconService
        )
        let uploadService = DataUploadService()

        return LocationViewModel(
            locationService: locationService,
            altitudeService: altitudeService,
            uuidProvider: uuidProvider,
            uploadService: uploadService,
            beaconService: beaconService,
            beaconConfig: beaconConfig
        )
    }

    static func makeMockViewModel() -> LocationViewModel {
        return LocationViewModel(
            locationService: MockLocationService(),
            altitudeService: MockAltitudeService(),
            uuidProvider: MockUUIDProvider(),
            uploadService: MockDataUploadService(),
            beaconService: MockBeaconService(),
            beaconConfig: MockBeaconConfiguration()
        )
    }
}
