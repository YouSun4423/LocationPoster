//
//  BeaconConfigurationProtocol.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/12/30.
//

import Foundation


protocol BeaconConfigurationProtocol {
    var monitoredBeaconUUIDs: [UUID] { get }
}
