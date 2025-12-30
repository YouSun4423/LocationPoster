//
//  MockBeaconConfiguration.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/12/30.
//

import Foundation


class MockBeaconConfiguration: BeaconConfigurationProtocol {
    var monitoredBeaconUUIDs: [UUID] {
        return [
            UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        ]
    }
}
