//
//  AltitudeService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import CoreMotion

final class AltitudeService: AltitudeServiceProtocol {
    private let altimeter = CMAltimeter()
    private(set) var currentPressure: Double?

    func start() {
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
                self?.currentPressure = data?.pressure.doubleValue
            }
        }
    }

    func stop() {
        altimeter.stopRelativeAltitudeUpdates()
    }
}
