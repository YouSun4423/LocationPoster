//
//  BeaconConfigurationService.swift
//  LocationPoster
//
//  Created by 矢口悠月 on 2025/12/30.
//

import Foundation


class BeaconConfigurationService: BeaconConfigurationProtocol {
    var monitoredBeaconUUIDs: [UUID] {
        // TODO: セイコーインスツルのソーラービーコンUUIDに置き換える
        // 実際のUUIDが判明したら、この配列に追加してください
        // 複数のビーコンを監視する場合は、カンマ区切りで追加

        let uuidStrings = [
            "E02CC25E-0049-4185-832C-3A65DB755D01",  // プレースホルダー1
        ]

        return uuidStrings.compactMap { UUID(uuidString: $0) }

        // 将来的なUserDefaults対応（UI設定画面追加時）:
        // if let uuidStrings = UserDefaults.standard.stringArray(forKey: "monitoredBeaconUUIDs") {
        //     return uuidStrings.compactMap { UUID(uuidString: $0) }
        // }
        // return []
    }

    // 将来的な拡張用メソッド（UI設定画面追加時）
    // func setMonitoredUUIDs(_ uuids: [UUID]) {
    //     let strings = uuids.map { $0.uuidString }
    //     UserDefaults.standard.set(strings, forKey: "monitoredBeaconUUIDs")
    // }
}
