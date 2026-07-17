import SwiftUI

struct LoadingView: View {
    let dim: ViewDimensions

    @State private var pulseScale: CGFloat = 1.0
    @State private var dotCount = 0

    var body: some View {
        ZStack {
            CyberBg.ignoresSafeArea()
            AnimatedGridBackground(color: CyberYellow, opacity: 0.05, animate: true)
                .ignoresSafeArea()
            FloatingParticles(count: 25, color: CyberYellow, speed: 0.6)
                .ignoresSafeArea()
                .allowsHitTesting(false)
            ScanlineOverlay(opacity: 0.02)
                .ignoresSafeArea()
            PulsingRadar(color: CyberYellow, count: 3, maxRadius: 100)
                .frame(width: 200, height: 200)
                .opacity(0.3)
                .offset(y: -dim.h * 0.15)

            VStack(spacing: dim.h * 0.025) {
                Spacer()

                VStack(spacing: dim.h * 0.012) {
                    GlitchText(
                        text: "Sensi Ultralock",
                        size: max(26, 34 * dim.scale),
                        color: .white,
                        glitchColor1: .red,
                        glitchColor2: .cyan,
                        intensity: 0.15,
                        weight: .black
                    )
                    .shadow(color: CyberYellow.opacity(0.65), radius: dim.w * 0.035)
                    .scaleEffect(pulseScale)

                    Text("FREE FIRE")
                        .font(.system(size: max(11, 13 * dim.scale), design: .monospaced).weight(.heavy))
                        .foregroundColor(CyberYellow)
                        .tracking(2)
                        .neonGlow(color: CyberYellow, radius: 4, intensity: 0.3)
                }

                Spacer().frame(height: dim.h * 0.03)

                HStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(CyberYellow)
                            .frame(width: 8, height: 8)
                            .opacity(dotCount > i ? 1 : 0.2)
                            .animation(.easeInOut(duration: 0.3).delay(Double(i) * 0.2), value: dotCount)
                    }
                }

                Text("ĐANG ĐỒNG BỘ HỆ THỐNG PLEXUS...")
                    .font(.system(size: max(9, dim.w * 0.026), design: .monospaced).weight(.bold))
                    .foregroundColor(CyberIceYellow)
                    .tracking(1.2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, dim.w * 0.08)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.06
            }
            startDotAnimation()
        }
    }

    private func startDotAnimation() {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 600_000_000)
                dotCount = (dotCount + 1) % 4
            }
        }
    }
}
