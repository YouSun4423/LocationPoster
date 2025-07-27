//
//  MockUUIDProvider.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import Foundation
@testable import LocationPoster

class MockUUIDProvider: DeviceUUIDProtocol {
    func get() -> String {
        return "TEST-UUID"
    }
}
