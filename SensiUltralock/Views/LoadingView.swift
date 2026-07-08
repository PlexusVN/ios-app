import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.025) {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: CyberYellow))
                    .scaleEffect(1.2)

                Text("ĐANG ĐỒNG BỘ HỆ THỐNG PLEXUS...")
                    .font(.system(size: max(10, geometry.size.width * 0.028), design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(CyberIceYellow)
                    .kerning(1.2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, geometry.size.width * 0.08)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}
