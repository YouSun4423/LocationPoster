//
//  BeaconServiceProtocol.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/12/30.
//

import Foundation
import CoreLocation


struct BeaconData {
    let uuid: String
    let major: Int
    let minor: Int
    let rssi: Int
    let proximity: CLProximity
    let accuracy: Double

    var proximityString: String {
        switch proximity {
        case .immediate:
            return "immediate"
        case .near:
            return "near"
        case .far:
            return "far"
        case .unknown:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }
}


protocol BeaconServiceProtocol {
    var currentBeacons: [BeaconData] { get }
    var onBeaconsUpdate: (([BeaconData]) -> Void)? { get set }
    func start(monitoringUUIDs: [UUID])
    func stop()
}
