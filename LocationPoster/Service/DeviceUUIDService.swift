//
//  DeviceUUIDService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/07/28.
//

import Foundation
import Security

class DeviceUUIDService {
    private static let service = "jp.mnb.LocationPoster.LocationPoster"
    private static let account = "persistent_device_uuid"

    static func get() -> String {
        // 既に保存済みならそれを返す
        if let data = load(), let uuid = String(data: data, encoding: .utf8) {
            return uuid
        }

        // なければ新しく生成して保存
        let newUUID = UUID().uuidString
        save(data: Data(newUUID.utf8))
        return newUUID
    }

    private static func save(data: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func load() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return (status == errSecSuccess) ? result as? Data : nil
    }
}
