//
//  LocationData.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/27.
//
import Foundation


struct LocationData: Encodable {
    let timestamp: Date
    let deviceUUID: String
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let floor: Int?
    let pressure: Double?
}
