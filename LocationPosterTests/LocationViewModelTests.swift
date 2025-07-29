//
//  LocationViewModelTests.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import XCTest
@testable import LocationPoster

final class LocationViewModelTests: XCTestCase {
    func testTrackingTriggersUpdateAndBuffer() {
        let mockLocationService = MockLocationService()
        let mockUUIDProvider = MockUUIDProvider()
        let mockAltitudeService = MockAltitudeService()
        let mockUploadService = MockDataUploadService()

        let viewModel = LocationViewModel(
            locationService: mockLocationService,
            altitudeService: mockAltitudeService,
            uuidProvider: mockUUIDProvider,
            uploadService: mockUploadService
        )

        let expectation = XCTestExpectation(description: "Async update")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(viewModel.locationText.contains("TEST-UUID"))
            XCTAssertEqual(mockUploadService.bufferedData.count, 1)
            XCTAssertEqual(mockUploadService.bufferedData.first?.floor, 2)
            expectation.fulfill()
        }

        viewModel.toggleTracking()

        wait(for: [expectation], timeout: 1.0)
    }
}
