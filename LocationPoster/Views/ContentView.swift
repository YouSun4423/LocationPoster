import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: LocationViewModel
    @State private var tapCount = 0
    @State private var showDebugToggle = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(white: 0.95)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            // 左端の隠しタップ領域
            HStack {
                Color.clear
                    .frame(width: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tapCount += 1
                        if tapCount >= 10 {
                            showDebugToggle = true
                            tapCount = 0
                        }
                    }
                Spacer()
            }

            VStack(spacing: 24) {
                Text("位置情報・気圧トラッカー")
                    .font(.title.bold())
                    .foregroundColor(.black)
                    .padding(.top, 40)

                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.locationText.components(separatedBy: "\n"), id: \.self) { line in
                        Text(line)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 8)
                .padding(.horizontal)

                // デバッグモード切り替え（隠し機能）
                if showDebugToggle {
                    HStack {
                        Image(systemName: viewModel.isDebugMode ? "ladybug.fill" : "ladybug")
                            .foregroundColor(viewModel.isDebugMode ? .orange : .gray)
                        Text("デバッグモード")
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                        Toggle("", isOn: $viewModel.isDebugMode)
                            .labelsHidden()
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .transition(.opacity)
                }

                Button(action: {
                    viewModel.toggleTracking()
                }) {
                    HStack {
                        Image(systemName: viewModel.isTracking ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(viewModel.isTracking ? "ストップ" : "スタート")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isTracking ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 6)
                }
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isTracking)

                if showDebugToggle && viewModel.isDebugMode {
                    Text("デバッグモード有効: データはサーバーに送信されません")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.bottom, 40)
            .animation(.easeInOut(duration: 0.3), value: showDebugToggle)
        }.alert("アプリの使用に権限が必要です", isPresented: $viewModel.isPermissionDenied) {
            Button("設定を開く") {
                openAppSettings()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("位置情報や気圧センサーの使用を許可してください。")
        }
        //.alert(item: $viewModel.errorMessage) { message in
        //    Alert(
        //        title: Text("送信エラー"),
        //        message: Text(message),
        //        dismissButton: .default(Text("OK"))
        //    )
        //}
    }
    
    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

extension String: @retroactive Identifiable {
    public var id: String { self }
}
