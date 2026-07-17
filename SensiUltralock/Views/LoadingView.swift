import SwiftUI

struct SyncLoadingView: View {
    @State private var progress: Double = 0

    var body: some View {
        ZStack {
            CyberGridBackground().ignoresSafeArea()
            VStack(spacing: 24) {
                ShieldLogo(size: 100)
                Text("ĐANG ĐỒNG BỘ HỆ THỐNG PLEXUS…")
                    .customTracking(2)
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundStyle(CyberTheme.cyberCyan)
                    .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.5)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CyberTheme.darkBorder)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CyberTheme.cyanGlowGradient)
                            .frame(width: geo.size.width * progress, height: 8)
                            .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.6)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)

                Text("\(Int(progress * 100))%")
                    .font(CyberTheme.monoFont.weight(.bold))
                    .foregroundStyle(CyberTheme.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) { progress = 0.9 }
        }
    }
}
