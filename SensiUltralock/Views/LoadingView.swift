import SwiftUI

struct LoadingView: View {
    let dim: ViewDimensions

    var body: some View {
        VStack(spacing: dim.h * 0.025) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: CyberYellow))
                .scaleEffect(1.2)

            Text("ĐANG ĐỒNG BỘ HỆ THỐNG PLEXUS...")
                .font(.system(size: max(10, dim.w * 0.028), design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(CyberIceYellow)
                .kerning(1.2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, dim.w * 0.08)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
