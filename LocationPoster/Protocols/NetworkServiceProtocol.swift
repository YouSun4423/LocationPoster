//
//  NetworkServiceProtocol.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

protocol NetworkServiceProtocol {
    func post(locationData: LocationData, to url: String)
}
