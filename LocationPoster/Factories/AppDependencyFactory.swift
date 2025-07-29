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
        let locationService = LocationService(
            uuidProvider: uuidProvider,
            altitudeService: altitudeService
        )
        let networkService = NetworkService()
        let uploadService = DataUploadService()

        return LocationViewModel(
            locationService: locationService,
            altitudeService: altitudeService,
            networkService: networkService,
            uuidProvider: uuidProvider,
            uploadService: uploadService
        )
    }

    static func makeMockViewModel() -> LocationViewModel {
        return LocationViewModel(
            locationService: MockLocationService(),
            altitudeService: MockAltitudeService(),
            networkService: MockNetworkService(),
            uuidProvider: MockUUIDProvider(),
            uploadService: MockUploadService()
        )
    }
}
