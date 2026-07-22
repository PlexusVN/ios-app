import SwiftUI
import Combine

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
    var size: CGFloat = 70

    var body: some View {
        ZStack {
            Circle()
                .stroke(CyberTheme.cyberCyan, style: StrokeStyle(lineWidth: 1.6, dash: [5, 4]))
                .frame(width: size, height: size)
                .cyberGlow(CyberTheme.cyberCyan, radius: 8, opacity: 0.5)

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
            .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.3)
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
                .stroke(CyberTheme.darkBorder, style: StrokeStyle(lineWidth: 8, dash: [3, 5]))
                .frame(width: 72, height: 72)

            Circle()
                .trim(from: 0, to: animatedPercent / 100)
                .stroke(CyberTheme.gaugeGradient, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 72, height: 72)
                .cyberGlow(CyberTheme.cyberCyan, radius: 8, opacity: 0.6)

            gaugeTicks

            VStack(spacing: 1) {
                Text("\(Int(animatedPercent))%")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(CyberTheme.textPrimary)
                    .cyberGlow(CyberTheme.cyberCyan, radius: 4, opacity: 0.4)
                Text("\(activeCount)/\(total)")
                    .font(.system(.caption2, design: .monospaced).weight(.bold))
                    .foregroundStyle(CyberTheme.textSecondary)
            }
        }
        .onAppear { animatedPercent = percent }
        .onChange(of: percent) { newValue in animatedPercent = newValue }
    }

    private var gaugeTicks: some View {
        ForEach(0..<60, id: \.self) { i in
            Rectangle()
                .fill(CyberTheme.textSecondary.opacity(i % 5 == 0 ? 0.5 : 0.2))
                .frame(width: i % 5 == 0 ? 1.5 : 1, height: i % 5 == 0 ? 6 : 3)
                .offset(y: -36)
                .rotationEffect(.degrees(Double(i) * 6))
        }
    }
}

// MARK: - Section Header

struct CyberSectionHeader: View {
    let title: String
    let accent: Color
    var badge: String? = nil

    var body: some View {
        HStack(spacing: 6) {
            Rectangle()
                .fill(accent)
                .frame(width: 3, height: 12)
                .cyberGlow(accent, radius: 2, opacity: 0.5)
            Text(title)
                .font(.system(.subheadline, design: .rounded).weight(.heavy))
                .foregroundStyle(CyberTheme.textPrimary)
                .tracking(1)
            Spacer()
            if let badge {
                Text(badge)
                    .font(.system(.caption2, design: .monospaced).weight(.bold))
                    .foregroundStyle(CyberTheme.cyberBgTop)
                    .padding(.horizontal, 6).padding(.vertical, 2)
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
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(CyberTheme.darkBorder)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Circle().stroke(isOn ? CyberTheme.cyberCyan : CyberTheme.textSecondary.opacity(0.4), lineWidth: 1.2)
                        )
                    Image(systemName: feature.isVipOnly ? "lock.fill" : "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(isOn ? CyberTheme.cyberGreen : CyberTheme.textSecondary)
                }
                .cyberGlow(isOn ? CyberTheme.cyberCyan : .clear, radius: 4, opacity: 0.4)

                VStack(alignment: .leading, spacing: 1) {
                    Text(feature.name)
                        .font(.system(.footnote, design: .rounded).weight(.bold))
                        .foregroundStyle(CyberTheme.textPrimary)
                    Text(feature.description)
                        .font(.caption2)
                        .foregroundStyle(CyberTheme.textSecondary)
                }

                Spacer()

                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(CyberTheme.dangerRed)
                } else {
                    CyberSwitch(isOn: isOn)
                }
            }
            .padding(.vertical, 3)
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
                .frame(width: 40, height: 22)
                .overlay(
                    Capsule().stroke(isOn ? CyberTheme.cyberGreen : CyberTheme.textSecondary.opacity(0.5), lineWidth: 0.8)
                )
                .cyberGlow(isOn ? CyberTheme.cyberCyan : .clear, radius: 4, opacity: 0.5)

            Circle()
                .fill(CyberTheme.textPrimary)
                .frame(width: 16, height: 16)
                .offset(x: isOn ? 9 : -9)
        }
    }
}

// MARK: - Tier Badge

struct TierBadge: View {
    let tier: KeyType

    var body: some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 10))
            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.heavy))
                .tracking(1)
        }
        .foregroundStyle(CyberTheme.cyberBgTop)
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(bagColor)
        .clipShape(Capsule())
        .cyberGlow(bagColor, radius: 4, opacity: 0.4)
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
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(CyberTheme.cyberGreen)
                .frame(width: 8, height: 8)
                .opacity(0.8)
                .cyberGlow(CyberTheme.cyberGreen, radius: 5, opacity: 0.7)
            Text("Hệ thống đang hoạt động tối ưu mượt !")
                .font(CyberTheme.monoFontSmall)
                .foregroundStyle(CyberTheme.cyberGreen)
                .tracking(0.5)
            Spacer()
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(CyberTheme.cyberGreen.opacity(0.4), lineWidth: 1)
        )
    }
}

// MARK: - Toast View

struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.footnote, design: .rounded).weight(.semibold))
            .foregroundStyle(CyberTheme.textPrimary)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(CyberTheme.cyberCardBg.opacity(0.95))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(CyberTheme.cyberCyan.opacity(0.6), lineWidth: 1)
            )
            .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.4)
            .padding(.horizontal, 24)
    }
}

// MARK: - Segmented Control

struct CyberSegmentedControl: View {
    let items: [(label: String, icon: String)]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { i in
                Button {
                    Haptics.medium()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selection = i
                    }
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: items[i].icon)
                            .font(.system(size: 10))
                        Text(items[i].label)
                            .font(.system(.caption2, design: .rounded).weight(.bold))
                            .tracking(1)
                    }
                    .foregroundStyle(selection == i ? CyberTheme.cyberBgTop : CyberTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(selection == i ? CyberTheme.cyberCyan : CyberTheme.darkBorder)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(selection == i ? .clear : CyberTheme.textSecondary.opacity(0.3), lineWidth: 0.8)
                    )
                    .cyberGlow(selection == i ? CyberTheme.cyberCyan : .clear, radius: 4, opacity: 0.4)
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
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundStyle(isSelected ? CyberTheme.cyberBgTop : CyberTheme.textSecondary)
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Capsule().fill(isSelected ? CyberTheme.cyberGreen : CyberTheme.darkBorder))
                .overlay(Capsule().stroke(isSelected ? .clear : CyberTheme.textSecondary.opacity(0.4), lineWidth: 0.8))
                .cyberGlow(isSelected ? CyberTheme.cyberGreen : .clear, radius: 3, opacity: 0.4)
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
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(CyberTheme.textSecondary)
                Text(value)
                    .font(.system(.caption, design: .monospaced).weight(.medium))
                    .foregroundStyle(CyberTheme.textPrimary)
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
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(copied ? CyberTheme.cyberGreen : CyberTheme.cyberCyan)
                    .frame(width: 26, height: 26)
                    .background(CyberTheme.darkBorder)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}
