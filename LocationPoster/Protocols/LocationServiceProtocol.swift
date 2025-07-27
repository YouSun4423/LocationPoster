//
//  LocationServiceProtocol.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

protocol LocationServiceProtocol {
    var onUpdate: ((LocationData) -> Void)? { get set }
    func start()
    func stop()
    func checkPermissions()  -> LocationPermissionStatus
}
