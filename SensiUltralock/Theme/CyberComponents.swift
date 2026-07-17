import SwiftUI
import Combine

// MARK: - iOS 15+ Tracking

extension Text {
    func customTracking(_ amount: CGFloat) -> Text {
        return self.kerning(amount)
    }
}

// MARK: - Toast Manager

class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var isVisible = false
    @Published var message = ""
    @Published var toastType: ToastType = .info

    enum ToastType {
        case success, warning, info

        var icon: String {
            switch self {
            case .success: return "✅"
            case .warning: return "⚠️"
            case .info:    return "ℹ️"
            }
        }

        var color: Color {
            switch self {
            case .success: return CyberTheme.cyberGreen
            case .warning: return CyberTheme.cyberGold
            case .info:    return CyberTheme.cyberCyan
            }
        }
    }

    private var dismissWork: DispatchWorkItem?

    func show(_ msg: String, type: ToastType = .info, duration: TimeInterval = 2.5) {
        dismissWork?.cancel()
        message = msg
        toastType = type
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            isVisible = true
        }
        let work = DispatchWorkItem { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.isVisible = false
            }
        }
        dismissWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }
}

// MARK: - Cyber Grid Background

struct CyberGridBackground: View {
    var lineSpacing: CGFloat = 42
    var lineColor: Color = CyberTheme.cyberCyan

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CyberTheme.bgGradient.ignoresSafeArea()

                RadialGradient(
                    colors: [CyberTheme.cyberPurple.opacity(0.15), .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: geo.size.width * 0.75
                )
                .ignoresSafeArea()

                Canvas { ctx, size in
                    var x: CGFloat = 0
                    while x <= size.width {
                        var p = Path()
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                        ctx.stroke(p, with: .color(lineColor.opacity(0.06)), lineWidth: 1)
                        x += lineSpacing
                    }
                    var y: CGFloat = 0
                    while y <= size.height {
                        var p = Path()
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                        ctx.stroke(p, with: .color(lineColor.opacity(0.06)), lineWidth: 1)
                        y += lineSpacing
                    }
                }

                LinearGradient(
                    colors: [.clear, CyberTheme.cyberGreen.opacity(0.025), .clear],
                    startPoint: .top, endPoint: .bottom
                )
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Shield Logo

struct ShieldLogo: View {
    var size: CGFloat = 120
    @State private var rotate: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(CyberTheme.cyberCyan, style: StrokeStyle(lineWidth: 2, dash: [6, 5]))
                .frame(width: size, height: size)
                .cyberGlow(CyberTheme.cyberCyan, radius: 12, opacity: 0.6)
                .rotationEffect(.degrees(rotate))

            Canvas { ctx, _ in
                let w = size * 0.55
                let h = size * 0.62
                var shield = Path()
                shield.move(to: CGPoint(x: 0, y: -h/2))
                shield.addLine(to: CGPoint(x: w/2, y: -h/2 + 8))
                shield.addLine(to: CGPoint(x: w/2, y: h/4))
                shield.addCurve(to: CGPoint(x: 0, y: h/2),
                                control1: CGPoint(x: w/2, y: h/2 - 4),
                                control2: CGPoint(x: w/3, y: h/2))
                shield.addCurve(to: CGPoint(x: -w/2, y: h/4),
                                control1: CGPoint(x: -w/3, y: h/2),
                                control2: CGPoint(x: -w/2, y: h/2 - 4))
                shield.addLine(to: CGPoint(x: -w/2, y: -h/2 + 8))
                shield.closeSubpath()
                ctx.stroke(shield, with: .color(CyberTheme.cyberCyan), lineWidth: 2.4)
                ctx.fill(shield, with: .color(CyberTheme.cyberCyan.opacity(0.10)))

                var ring = Path()
                ring.addEllipse(in: CGRect(x: -size*0.07, y: -size*0.07, width: size*0.14, height: size*0.14))
                ctx.stroke(ring, with: .color(CyberTheme.cyberGreen), lineWidth: 2)
                ctx.fill(ring, with: .color(CyberTheme.cyberGreen.opacity(0.5)))

                var cross = Path()
                cross.move(to: CGPoint(x: -size*0.28, y: 0))
                cross.addLine(to: CGPoint(x: -size*0.10, y: 0))
                cross.move(to: CGPoint(x: size*0.10, y: 0))
                cross.addLine(to: CGPoint(x: size*0.28, y: 0))
                cross.move(to: CGPoint(x: 0, y: -size*0.28))
                cross.addLine(to: CGPoint(x: 0, y: -size*0.10))
                cross.move(to: CGPoint(x: 0, y: size*0.10))
                cross.addLine(to: CGPoint(x: 0, y: size*0.28))
                ctx.stroke(cross, with: .color(CyberTheme.cyberCyan.opacity(0.8)), lineWidth: 1.4)
            }
            .frame(width: size, height: size)
            .cyberGlow(CyberTheme.cyberCyan, radius: 10, opacity: 0.4)
        }
        .onAppear {
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                rotate = 360
            }
        }
    }
}

// MARK: - Circular Optimization Gauge

struct CyberGauge: View {
    let percent: Double
    let activeCount: Int
    let total: Int
    @State private var animatedPercent: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(CyberTheme.darkBorder, style: StrokeStyle(lineWidth: 12, dash: [4, 6]))
                .frame(width: 100, height: 100)

            Circle()
                .trim(from: 0, to: animatedPercent / 100)
                .stroke(CyberTheme.gaugeGradient, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 100, height: 100)
                .cyberGlow(CyberTheme.cyberCyan, radius: 12, opacity: 0.7)

            gaugeTicks

            VStack(spacing: 2) {
                Text("\(Int(animatedPercent))%")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(CyberTheme.textPrimary)
                    .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.5)
                Text("\(activeCount)/\(total)")
                    .customTracking(1)
                    .font(CyberTheme.monoFontSmall)
                    .foregroundColor(CyberTheme.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) { animatedPercent = percent }
        }
        .onReceive(Just(percent)) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedPercent = newValue
            }
        }
    }

    private var gaugeTicks: some View {
        ForEach(0..<60, id: \.self) { i in
            GaugeTick(index: i)
        }
    }
}

private struct GaugeTick: View {
    let index: Int
    var body: some View {
        let major = index % 5 == 0
        return Rectangle()
            .fill(CyberTheme.textSecondary.opacity(major ? 0.5 : 0.2))
            .frame(width: major ? 2 : 1, height: major ? 8 : 4)
            .offset(y: -50)
            .rotationEffect(.degrees(Double(index) * 6))
    }
}

// MARK: - Section Header

struct CyberSectionHeader: View {
    let title: String
    let accent: Color
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(accent)
                .frame(width: 4, height: 16)
                .cyberGlow(accent, radius: 3, opacity: 0.6)
            Text(title)
                .customTracking(1.5)
                .font(.system(.headline, design: .rounded).weight(.heavy))
                .foregroundColor(CyberTheme.textPrimary)
            Spacer()
            if let badge {
                Text(badge)
                    .font(.system(.caption2, design: .monospaced).weight(.bold))
                    .foregroundColor(CyberTheme.cyberBgTop)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(accent)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - Feature Toggle Row

struct CyberFeatureToggle: View {
    let feature: ModFeature
    let isOn: Bool
    let locked: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(CyberTheme.darkBorder)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle().stroke(isOn ? CyberTheme.cyberCyan : CyberTheme.textSecondary.opacity(0.4), lineWidth: 1.5)
                        )
                    Image(systemName: feature.isVipOnly ? "lock.fill" : "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isOn ? CyberTheme.cyberGreen : CyberTheme.textSecondary)
                }
                .cyberGlow(isOn ? CyberTheme.cyberCyan : .clear, radius: 6, opacity: 0.5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(feature.name)
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundColor(CyberTheme.textPrimary)
                    Text(feature.description)
                        .font(.caption)
                        .foregroundColor(CyberTheme.textSecondary)
                }

                Spacer()

                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13))
                        .foregroundColor(CyberTheme.dangerRed)
                } else {
                    CyberSwitch(isOn: isOn)
                }
            }
            .padding(.vertical, 6)
            .opacity(locked ? 0.55 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(locked)
    }
}

// MARK: - Custom Switch

struct CyberSwitch: View {
    let isOn: Bool

    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? CyberTheme.cyberCyan : CyberTheme.darkBorder)
                .frame(width: 50, height: 26)
                .overlay(
                    Capsule().stroke(isOn ? CyberTheme.cyberGreen : CyberTheme.textSecondary.opacity(0.5), lineWidth: 1)
                )
                .cyberGlow(isOn ? CyberTheme.cyberCyan : .clear, radius: 5, opacity: 0.6)

            Circle()
                .fill(CyberTheme.textPrimary)
                .frame(width: 20, height: 20)
                .offset(x: isOn ? 12 : -12)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        }
    }
}

// MARK: - Tier Badge

struct TierBadge: View {
    let tier: KeyType

    var body: some View {
        HStack(spacing: 6) {
            Text(emoji)
            Text(label)
                .customTracking(1.5)
                .font(.system(.caption, design: .rounded).weight(.heavy))
        }
        .foregroundColor(CyberTheme.cyberBgTop)
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(bagColor)
        .clipShape(Capsule())
        .cyberGlow(bagColor, radius: 6, opacity: 0.5)
    }

    private var emoji: String {
        switch tier {
        case .vip:  return "👑"
        case .pro:  return "⚡"
        case .basic: return "👤"
        }
    }
    private var label: String {
        switch tier {
        case .vip:  return "VIP PREMIUM"
        case .pro:  return "PRO SPECIAL"
        case .basic: return "FREE BASIC"
        }
    }
    private var bagColor: Color {
        switch tier {
        case .vip:  return CyberTheme.cyberGold
        case .pro:  return CyberTheme.cyberPurple
        case .basic: return CyberTheme.cyberCyan
        }
    }
}

// MARK: - Heartbeat Status Bar

struct HeartbeatBar: View {
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(CyberTheme.cyberGreen)
                .frame(width: 8, height: 8)
                .opacity(pulse ? 1 : 0.3)
                .cyberGlow(CyberTheme.cyberGreen, radius: 5, opacity: 0.7)
            Text("Hệ thống đang hoạt động tối ưu mượt !")
                .customTracking(0.5)
                .font(CyberTheme.monoFontSmall)
                .foregroundColor(CyberTheme.cyberGreen)
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(CyberTheme.cyberGreen.opacity(0.4), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) { pulse = true }
        }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let text: String
    let type: ToastManager.ToastType

    var body: some View {
        HStack(spacing: 8) {
            Text(type.icon).font(.system(size: 14))
            Text(text)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                .foregroundColor(CyberTheme.textPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, 18).padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(CyberTheme.cyberCardBg.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(type.color.opacity(0.6), lineWidth: 1.2)
        )
        .cyberGlow(type.color, radius: 8, opacity: 0.5)
        .padding(.horizontal, 24)
    }
}

// MARK: - Segmented Control

struct CyberSegmentedControl: View {
    let items: [(label: String, icon: String)]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(items.indices, id: \.self) { i in
                Button {
                    Haptics.medium()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = i
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: items[i].icon)
                        Text(items[i].label)
                            .customTracking(1.5)
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                    }
                    .foregroundColor(selection == i ? CyberTheme.cyberBgTop : CyberTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(selection == i ? CyberTheme.cyberCyan : CyberTheme.darkBorder)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(selection == i ? .clear : CyberTheme.textSecondary.opacity(0.3), lineWidth: 1)
                    )
                    .cyberGlow(selection == i ? CyberTheme.cyberCyan : .clear, radius: 6, opacity: 0.5)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Latency Chip

struct LatencyChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: { Haptics.medium(); action() }) {
            Text(label)
                .font(.system(.subheadline, design: .monospaced).weight(.bold))
                .foregroundColor(isSelected ? CyberTheme.cyberBgTop : CyberTheme.textSecondary)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(Capsule().fill(isSelected ? CyberTheme.cyberGreen : CyberTheme.darkBorder))
                .overlay(Capsule().stroke(isSelected ? .clear : CyberTheme.textSecondary.opacity(0.4), lineWidth: 1))
                .cyberGlow(isSelected ? CyberTheme.cyberGreen : .clear, radius: 5, opacity: 0.5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Copyable Info Row

struct CopyableRow: View {
    let label: String
    let value: String
    @State private var copied = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(CyberTheme.textSecondary)
                Text(value)
                    .font(CyberTheme.monoFont)
                    .foregroundColor(CyberTheme.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            Button {
                UIPasteboard.general.string = value
                Haptics.light()
                withAnimation { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                    withAnimation { copied = false }
                }
            } label: {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(copied ? CyberTheme.cyberGreen : CyberTheme.cyberCyan)
                    .frame(width: 32, height: 32)
                    .background(CyberTheme.darkBorder)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }
}
