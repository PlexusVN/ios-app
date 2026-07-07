import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: CyberYellow))
                .scaleEffect(1.2)

            Text("ĐANG ĐỒNG BỘ HỆ THỐNG PLEXUS...")
                .font(.system(size: 11, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(CyberIceYellow)
                .tracking(1.2)
        }
    }
}
