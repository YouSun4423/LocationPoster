import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: LocationViewModel
    @State private var tapCount = 0
    @State private var showDebugToggle = false
    @State private var selectedTab = 0
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // モダンなグラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.95, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 上部余白（タイトル削除）
                Spacer()
                    .frame(height: 20)

                // タブバー
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 0
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.subheadline)
                            Text("メイン")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(selectedTab == 0 ? .white : .white.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == 0 ? Color.blue : Color.clear)
                        )
                    }

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = 1
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "wave.3.right")
                                .font(.subheadline)
                            Text("ビーコン")
                                .font(.subheadline)
                            if viewModel.beaconList.count > 0 {
                                Text("\(viewModel.beaconList.count)")
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(Color.red)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundColor(selectedTab == 1 ? .white : .white.opacity(0.6))
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == 1 ? Color.purple : Color.clear)
                        )
                    }
                }
                .padding(3)
                .background(
                    RoundedRectangle(cornerRadius: 13)
                        .fill(Color.black.opacity(0.2))
                )
                .padding(.horizontal)
                .padding(.bottom, 10)

                // スクロール可能なコンテンツエリア
                TabView(selection: $selectedTab) {
                    // メインタブ
                    ScrollView {
                        VStack(spacing: 20) {
                            mainContentView()
                        }
                        .padding(.bottom, 100)
                    }
                    .tag(0)

                    // ビーコンリストタブ
                    ScrollView {
                        VStack(spacing: 20) {
                            beaconListView()
                        }
                        .padding(.bottom, 100)
                    }
                    .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                Spacer()

                // デバッグモード（固定表示 - ボタンの上）
                if showDebugToggle {
                    debugModeCard()
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                        .transition(.scale.combined(with: .opacity))
                }

                // 固定ボタン（下部）
                VStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.toggleTracking()
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: viewModel.isTracking ? "stop.circle.fill" : "play.circle.fill")
                                .font(.title2)
                            Text(viewModel.isTracking ? "トラッキングを停止" : "トラッキングを開始")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: viewModel.isTracking
                                            ? [Color.red, Color.red.opacity(0.8)]
                                            : [Color.green, Color.green.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: (viewModel.isTracking ? Color.red : Color.green).opacity(0.3), radius: 10, x: 0, y: 5)
                        )
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    .scaleEffect(viewModel.isTracking ? 0.98 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isTracking)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.95, green: 0.97, blue: 1.0).opacity(0),
                            Color(red: 0.95, green: 0.97, blue: 1.0)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                )
            }
            .contentShape(Rectangle())
            .onTapGesture {
                tapCount += 1
                if tapCount >= 10 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        showDebugToggle = true
                    }
                    tapCount = 0
                }
            }
        }
        .alert("アプリの使用に権限が必要です", isPresented: $viewModel.isPermissionDenied) {
            Button("設定を開く") {
                openAppSettings()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("位置情報や気圧センサーの使用を許可してください。")
        }
        .alert("送信エラー", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    // MARK: - View Components

    @ViewBuilder
    private func mainContentView() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                    .font(.title3)
                Text("リアルタイムデータ")
                    .font(.headline)
                Spacer()
                if viewModel.isTracking {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("記録中")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.locationText.components(separatedBy: "\n"), id: \.self) { line in
                    if !line.isEmpty {
                        DataRowView(text: line)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal)
    }

    @ViewBuilder
    private func debugModeCard() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: viewModel.isDebugMode ? "ladybug.fill" : "ladybug")
                    .foregroundColor(viewModel.isDebugMode ? Color.cyan : Color.gray.opacity(0.6))
                    .font(.title3)
                Text("デバッグモード")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: $viewModel.isDebugMode)
                    .labelsHidden()
                    .tint(Color.cyan)
                    .disabled(viewModel.isTracking)
            }

            if viewModel.isDebugMode {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color(red: 1.0, green: 0.95, blue: 0.3))
                    Text("データはサーバーに送信されません")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }

            if viewModel.isTracking {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Text("計測中は変更できません")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.25, green: 0.2, blue: 0.45),
                            Color(red: 0.3, green: 0.25, blue: 0.55)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(red: 0.25, green: 0.2, blue: 0.45).opacity(0.5), radius: 10, x: 0, y: 4)
        )
    }

    @ViewBuilder
    private func beaconListView() -> some View {
        VStack(spacing: 16) {
            // ヘッダーカード（メインタブと統一）
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "wave.3.right")
                        .foregroundColor(.purple)
                        .font(.title3)
                    Text("検出ビーコン")
                        .font(.headline)
                    Spacer()

                    // 記録中とビーコン数を一列に
                    HStack(spacing: 8) {
                        if viewModel.isTracking {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("記録中")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text("\(viewModel.beaconList.count)個")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()

                // ビーコンリスト
                if viewModel.beaconList.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.purple.opacity(0.3))
                        Text("ビーコンが検出されていません")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(Array(viewModel.beaconList.enumerated()), id: \.offset) { index, beacon in
                            BeaconCardView(beacon: beacon, index: index + 1)
                        }
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 5)
            )
            .padding(.horizontal)
        }
    }
}

// データ行コンポーネント
struct DataRowView: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            if let icon = getIcon(for: text) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.body)
                    .frame(width: 24)
            }

            if let (label, value) = parseData(text) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(value)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.primary)
                        .fontWeight(.medium)
                }
            } else {
                Text(text)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func parseData(_ text: String) -> (String, String)? {
        let components = text.components(separatedBy: ": ")
        guard components.count == 2 else { return nil }
        return (components[0], components[1])
    }

    private func getIcon(for text: String) -> String? {
        if text.contains("デバイスID") { return "iphone" }
        if text.contains("時刻") { return "clock" }
        if text.contains("緯度") { return "location.north" }
        if text.contains("経度") { return "location" }
        if text.contains("高度") { return "arrow.up.and.down" }
        if text.contains("フロア") { return "building.2" }
        if text.contains("気圧") { return "gauge.medium" }
        if text.contains("ビーコン") { return "wave.3.right" }
        if text.contains("Major") || text.contains("Minor") { return "number" }
        if text.contains("RSSI") { return "antenna.radiowaves.left.and.right" }
        if text.contains("距離") { return "ruler" }
        if text.contains("精度") { return "scope" }
        return nil
    }
}

// ビーコンカードコンポーネント
struct BeaconCardView: View {
    let beacon: BeaconData
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "wave.3.right.circle.fill")
                        .foregroundColor(.purple)
                        .font(.title3)
                    Text("Beacon #\(index)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                Spacer()
                proximityBadge(beacon.proximityString)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            VStack(spacing: 10) {
                beaconDataRow(icon: "barcode", label: "UUID", value: beacon.uuid)
                beaconDataRow(icon: "number.circle", label: "Major", value: "\(beacon.major)")
                beaconDataRow(icon: "number.square", label: "Minor", value: "\(beacon.minor)")
                beaconDataRow(icon: "antenna.radiowaves.left.and.right", label: "RSSI", value: "\(beacon.rssi) dBm")
                beaconDataRow(icon: "ruler", label: "精度", value: String(format: "%.2f m", beacon.accuracy))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.purple.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: Color.purple.opacity(0.15), radius: 8, x: 0, y: 4)
        )
    }

    private func beaconDataRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.purple.opacity(0.8))
                .font(.body)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                Text(value)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }

    private func proximityBadge(_ proximity: String) -> some View {
        let (color, text) = proximityInfo(proximity)
        return HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(color.opacity(0.3))
                .overlay(
                    Capsule()
                        .stroke(color, lineWidth: 1)
                )
        )
    }

    private func proximityInfo(_ proximity: String) -> (Color, String) {
        switch proximity {
        case "immediate":
            return (Color.green, "至近")
        case "near":
            return (Color.orange, "近距離")
        case "far":
            return (Color.red, "遠距離")
        default:
            return (Color.gray, "不明")
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
