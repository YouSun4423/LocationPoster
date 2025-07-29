//
//  MockNetworkService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import Foundation
@testable import LocationPoster

class MockNetworkService: NetworkServiceProtocol {
    var didPost = false
    var lastPostedData: LocationData?

    func post(locationData: LocationData, to url: String, completion: @escaping (Result<Void, Error>) -> Void) {
        didPost = true
        lastPostedData = locationData
    }
}
