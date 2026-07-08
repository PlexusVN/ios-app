import SwiftUI

struct LoadingView: View {
    private var w: CGFloat { UIScreen.main.bounds.width }

    var body: some View {
        VStack(spacing: UIScreen.main.bounds.height * 0.025) {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: CyberYellow))
                .scaleEffect(1.2)

            Text("ĐANG ĐỒNG BỘ HỆ THỐNG PLEXUS...")
                .font(.system(size: max(10, w * 0.028), design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(CyberIceYellow)
                .kerning(1.2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, w * 0.08)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
