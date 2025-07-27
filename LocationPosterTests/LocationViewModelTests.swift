//
//  LocationViewModelTests.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import XCTest
@testable import LocationPoster

final class LocationViewModelTests: XCTestCase {
    func testTrackingTriggersUpdateAndPost() {
        let mockLocationService = MockLocationService()
        let mockNetworkService = MockNetworkService()
        let mockUUIDProvider = MockUUIDProvider()

        let viewModel = LocationViewModel(
            locationService: mockLocationService,
            networkService: mockNetworkService,
            uuidProvider: mockUUIDProvider
        )

        viewModel.toggleTracking()

        // 少し待つ（非同期UI更新）
        let expectation = XCTestExpectation(description: "Async update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(viewModel.locationText.contains("TEST-UUID"))
            XCTAssertTrue(mockNetworkService.didPost)
            XCTAssertEqual(mockNetworkService.lastPostedData?.floor, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
