//
//  MockAltitudeService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//


import Foundation
@testable import LocationPoster

class MockAltitudeService: AltitudeServiceProtocol {
    var currentPressure: Double?
    var didStart = false
    var didStop = false

    func start() {
        didStart = true
        currentPressure = 101.25 // 海面気圧の例（kPa）
    }

    func stop() {
        didStop = true
    }
}
