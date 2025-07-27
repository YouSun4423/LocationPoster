//
//  AltitudeServiceProtocol.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

protocol AltitudeServiceProtocol {
    var currentPressure: Double? { get }
    func start()
    func stop()
}
