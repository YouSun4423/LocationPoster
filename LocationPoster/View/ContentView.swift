import SwiftUI

struct ContentView: View {
    @State private var isTracking = false
    @State private var locationText = "未取得"
    private let locationService = LocationService()
    private let networkService = NetworkService()
    private let postURL = "https://your-server.com/endpoint"

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.white,
                    Color(white: 0.95)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 24) {
                Text("位置情報・気圧トラッカー")
                    .font(.title.bold())
                    .foregroundColor(.black) // or .primary
                    .padding(.top, 40)

                // 情報カード
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(locationText.components(separatedBy: "\n"), id: \.self) { line in
                        Text(line)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.black) // or .primary
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 8)
                .padding(.horizontal)

                // トグルボタン
                Button(action: {
                    isTracking.toggle()
                    isTracking ? locationService.start() : locationService.stop()
                }) {
                    HStack {
                        Image(systemName: isTracking ? "stop.circle.fill" : "play.circle.fill")
                            .font(.title2)
                        Text(isTracking ? "ストップ" : "スタート")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isTracking ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 6)
                }
                .padding(.horizontal)
                .animation(.easeInOut(duration: 0.2), value: isTracking)

                Spacer()
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            let deviceUUID = DeviceUUIDService.get()
            locationService.onUpdate = { data in
                DispatchQueue.main.async {
                    locationText = """
                    デバイスID: \(deviceUUID)
                    時刻: \(formatDate(data.timestamp))
                    緯度: \(data.latitude)
                    経度: \(data.longitude)
                    高度: \(data.altitude)
                    フロア: \(data.floor ?? -1)
                    気圧: \(data.pressure ?? 0.0)
                    """
                }
                networkService.post(locationData: data, to: postURL)
            }
        }
    }

    // 日時整形
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
}
