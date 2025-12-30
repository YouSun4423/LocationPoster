# LocationPoster

iOSデバイスの位置情報・気圧データ・BLEビーコン情報をリアルタイムで取得し、指定されたサーバーへCSV形式でPOST送信するユーティリティアプリです。

## 概要

LocationPosterは、研究やフィールドワークでの位置情報収集を支援するiOSアプリケーションです。GPS位置情報、気圧センサーデータ、BLEビーコン（iBeacon）検出情報を統合し、サーバーへ自動送信します。

## 主な機能

- **位置情報取得**: GPS座標（緯度・経度・高度・フロア）のリアルタイム取得
- **気圧センサー**: 高精度な気圧データの取得
- **BLEビーコン検出**: iBeacon対応ビーコンの検出と測距
  - UUID、Major、Minor、RSSI、距離（Proximity）、精度（Accuracy）を取得
  - 複数ビーコンの同時検出に対応
- **自動データ送信**: 収集したデータをCSV形式でサーバーへPOST
- **デバッグモード**: 開発時のサーバー負荷軽減用の隠し機能

## 技術仕様

### 対応デバイス
- iOS 14.0以降
- iPhone（位置情報サービス、気圧センサー、Bluetooth対応デバイス）

### 使用技術
- **言語**: Swift
- **フレームワーク**: SwiftUI, CoreLocation, CoreMotion, Combine
- **アーキテクチャ**: Protocol-oriented design, Dependency Injection

### データフォーマット

送信されるCSVフォーマット:

```csv
deviceUUID,timestamp,latitude,longitude,altitude,floor,pressure,beaconUUID,beaconMajor,beaconMinor,beaconRSSI,beaconProximity,beaconAccuracy,correlationID
```

#### フィールド説明
- `deviceUUID`: デバイス固有のUUID
- `timestamp`: タイムスタンプ（yyyyMMddHHmmss形式）
- `latitude`: 緯度
- `longitude`: 経度
- `altitude`: 高度（メートル）
- `floor`: フロア階数（利用可能な場合）
- `pressure`: 気圧（kPa）
- `beaconUUID`: 検出されたビーコンのUUID
- `beaconMajor`: ビーコンのMajor値
- `beaconMinor`: ビーコンのMinor値
- `beaconRSSI`: 受信信号強度
- `beaconProximity`: 距離区分（immediate/near/far/unknown）
- `beaconAccuracy`: 推定距離（メートル）
- `correlationID`: 同時刻に検出された複数ビーコンの紐付けID

**複数ビーコン検出時の動作**:
- 同時に複数のビーコンが検出された場合、各ビーコンごとに1行のデータが生成されます
- 同じ位置更新で検出されたビーコンは、同一の`correlationID`で関連付けられます

## セットアップ

### 1. クローン

```bash
git clone https://github.com/yourusername/LocationPoster.git
cd LocationPoster
```

### 2. Xcodeで開く

```bash
open LocationPoster.xcodeproj
```

### 3. ビーコンUUIDの設定

`LocationPoster/Services/BeaconConfigurationService.swift`を編集し、監視対象のビーコンUUIDを設定します:

```swift
let uuidStrings = [
    "YOUR-BEACON-UUID-HERE",
]
```

### 4. サーバーURLの設定

`LocationPoster/ViewModels/LocationViewModel.swift`の`postURL`を編集:

```swift
private let postURL = "https://your-server.com/upload_endpoint.php"
```

### 5. ビルド・実行

1. 実機を接続
2. Xcodeでターゲットデバイスを選択
3. ビルド・実行（Cmd + R）

## 使い方

### 基本操作

1. アプリを起動
2. 位置情報とモーションセンサーの権限を許可
3. 「スタート」ボタンをタップしてトラッキング開始
4. 「ストップ」ボタンをタップして停止・データ送信

### デバッグモード（隠し機能）

開発・テスト時にサーバーへの送信を抑制する機能:

1. 画面左端を10回タップ
2. デバッグモードトグルが表示される
3. トグルをONにするとサーバー送信が無効化され、コンソールにCSVが出力される

## プロジェクト構成

```
LocationPoster/
├── Models/
│   └── LocationData.swift              # データモデル
├── Views/
│   └── ContentView.swift               # メインUI
├── ViewModels/
│   └── LocationViewModel.swift         # ビジネスロジック
├── Services/
│   ├── LocationService.swift           # 位置情報サービス
│   ├── AltitudeService.swift           # 気圧センサーサービス
│   ├── BeaconService.swift             # ビーコン検出サービス
│   ├── BeaconConfigurationService.swift # ビーコン設定
│   ├── DataUploadService.swift         # データアップロードサービス
│   └── DeviceUUIDService.swift         # デバイスUUID管理
├── Protocols/
│   ├── LocationServiceProtocol.swift
│   ├── AltitudeServiceProtocol.swift
│   ├── BeaconServiceProtocol.swift
│   ├── BeaconConfigurationProtocol.swift
│   ├── DataUploadServiceProtocol.swift
│   └── DeviceUUIDProtocol.swift
├── Factories/
│   └── AppDependencyFactory.swift      # 依存性注入ファクトリ
└── Mocks/
    ├── MockLocationService.swift       # テスト用Mock
    ├── MockBeaconService.swift
    ├── MockBeaconConfiguration.swift
    └── MockDataUploadService.swift
```

## 権限設定

Info.plistに以下の権限が設定されています:

- **NSLocationWhenInUseUsageDescription**: 位置情報の使用許可
- **NSLocationAlwaysAndWhenInUseUsageDescription**: バックグラウンド位置情報
- **NSMotionUsageDescription**: 気圧センサーの使用許可
- **NSBluetoothAlwaysUsageDescription**: Bluetooth使用許可（ビーコン検出用）

## ビーコン検出について

### 対応ビーコン

- iBeacon規格準拠のBLEビーコン
- セイコーインスツル株式会社製ソーラービーコンで動作確認済み

### 検出仕様

- **Ranging**: リアルタイムで距離測定
- **Monitoring**: リージョン出入りの検知
- **複数検出**: 同時に複数のビーコンを検出可能
- **UUID管理**: 設定ファイルで監視対象UUIDを管理

## 開発

### テスト

プロトコルベース設計により、各コンポーネントは独立してテスト可能です。

```swift
// 例: ViewModelのテスト
let mockLocationService = MockLocationService()
let viewModel = LocationViewModel(
    locationService: mockLocationService,
    // ... その他のMock依存性
)
```

### 拡張

#### 新しいセンサーの追加

1. プロトコル定義（`Protocols/`）
2. サービス実装（`Services/`）
3. Mock実装（`Mocks/`）
4. ViewModelへの統合
5. AppDependencyFactoryでの依存性注入

## トラブルシューティング

### ビーコンが検出されない

- ビーコンのUUIDが正しく設定されているか確認
- Bluetooth権限が許可されているか確認
- ビーコンの電池残量を確認
- ビーコンが範囲内（通常10m以内）にあるか確認

### データが送信されない

- ネットワーク接続を確認
- サーバーURLが正しいか確認
- サーバー側のエンドポイントが正常に動作しているか確認
- デバッグモードがOFFになっているか確認

### 位置情報が取得できない

- 位置情報サービスが有効か確認
- アプリに位置情報権限が付与されているか確認（設定アプリで確認）

## ライセンス

このプロジェクトのライセンスについては、LICENSEファイルを参照してください。

## 貢献

プルリクエストを歓迎します。大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 作者

矢口悠月

## 更新履歴

### 2025-12-30
- BLEビーコン検出機能を追加
- 複数ビーコンの同時検出に対応
- CSVフォーマットにビーコンデータフィールドを追加
- デバッグモード機能を追加
- セイコーインスツルビーコン対応

### 2025-07-28
- 初回リリース
- 位置情報・気圧データの取得機能
- サーバーへのCSV送信機能
