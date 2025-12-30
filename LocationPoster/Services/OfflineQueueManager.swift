//
//  OfflineQueueManager.swift
//  LocationPoster
//
//  Created by Claude Code on 2025/12/30.
//

import Foundation

class OfflineQueueManager: OfflineQueueManagerProtocol {
    private let fileManager = FileManager.default
    private let fileName = "pending_uploads.json"
    private let maxQueueSize = 100
    private let fileAccessQueue = DispatchQueue(label: "com.locationposter.offlinequeue")

    private var fileURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let appDirectory = appSupport.appendingPathComponent("LocationPoster")

        // ディレクトリが存在しない場合は作成
        try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)

        return appDirectory.appendingPathComponent(fileName)
    }

    func enqueue(csvData: String, destinationURL: String) {
        fileAccessQueue.async { [weak self] in
            guard let self = self else { return }

            var uploads = self.loadFromDisk()

            // キューサイズ制限 (最も古いものを削除)
            if uploads.count >= self.maxQueueSize {
                uploads.removeFirst()
                print("[OfflineQueue] ⚠️ キューが最大サイズに達しました。最も古いアップロードを削除します")
            }

            let newUpload = PersistedUpload(csvData: csvData, destinationURL: destinationURL)
            uploads.append(newUpload)

            self.saveToDisk(uploads)
            print("[OfflineQueue] 📥 アップロードをキューに追加しました (ID: \(newUpload.id))")
        }
    }

    func getPendingUploads() -> [PersistedUpload] {
        return fileAccessQueue.sync {
            return loadFromDisk()
        }
    }

    func remove(uploadID: UUID) {
        fileAccessQueue.async { [weak self] in
            guard let self = self else { return }

            var uploads = self.loadFromDisk()
            uploads.removeAll { $0.id == uploadID }
            self.saveToDisk(uploads)
            print("[OfflineQueue] 🗑️ アップロードをキューから削除しました (ID: \(uploadID))")
        }
    }

    func removeAll() {
        fileAccessQueue.async { [weak self] in
            guard let self = self else { return }

            self.saveToDisk([])
            print("[OfflineQueue] 🗑️ キューをクリアしました")
        }
    }

    func incrementAttemptCount(uploadID: UUID) {
        fileAccessQueue.async { [weak self] in
            guard let self = self else { return }

            var uploads = self.loadFromDisk()

            if let index = uploads.firstIndex(where: { $0.id == uploadID }) {
                let oldUpload = uploads[index]
                let updatedUpload = PersistedUpload(
                    csvData: oldUpload.csvData,
                    destinationURL: oldUpload.destinationURL,
                    attemptCount: oldUpload.attemptCount + 1
                )

                // IDとtimestampを保持するため、元のオブジェクトを置き換え
                uploads[index] = PersistedUpload(
                    csvData: oldUpload.csvData,
                    destinationURL: oldUpload.destinationURL,
                    attemptCount: oldUpload.attemptCount + 1
                )

                self.saveToDisk(uploads)
                print("[OfflineQueue] 🔄 試行回数を増加しました (ID: \(uploadID), 回数: \(updatedUpload.attemptCount))")
            }
        }
    }

    // MARK: - Private Methods

    private func loadFromDisk() -> [PersistedUpload] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let uploads = try JSONDecoder().decode([PersistedUpload].self, from: data)
            return uploads
        } catch {
            print("[OfflineQueue] ❌ キューの読み込みに失敗しました: \(error.localizedDescription)")
            return []
        }
    }

    private func saveToDisk(_ uploads: [PersistedUpload]) {
        do {
            let data = try JSONEncoder().encode(uploads)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("[OfflineQueue] ❌ キューの保存に失敗しました: \(error.localizedDescription)")
        }
    }
}
