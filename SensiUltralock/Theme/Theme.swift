import SwiftUI

// MARK: - Cyberpunk Neon Theme (Yellow/Gold)

enum CyberTheme {
    static let cyberBgTop    = Color(hexARGB: 0xFF06020E)
    static let cyberBgMid    = Color(hexARGB: 0xFF1A0800)
    static let cyberBgBottom = Color(hexARGB: 0xFF06020E)
    static let cyberCardBg   = Color(hexARGB: 0x90332000)
    static let cyberCardSoft = Color(hexARGB: 0xFF332000)

    static let cyberCyan     = Color(hexARGB: 0xFFFFD700)
    static let cyberIceBlue  = Color(hexARGB: 0xFFFFF8E1)
    static let cyberGold     = Color(hexARGB: 0xFFFFD54F)
    static let cyberGreen    = Color(hexARGB: 0xFF00FF94)
    static let cyberPurple   = Color(hexARGB: 0xFFFFB300)
    static let cyberPurpleSoft = Color(hexARGB: 0x80FFB300)

    static let textPrimary   = Color.white
    static let textSecondary = Color(hexARGB: 0xFFFFE0B2)
    static let darkBorder    = Color(hexARGB: 0xFF4A3000)

    static let dangerRed     = Color(hexARGB: 0xFFFF5252)
    static let neonPink      = Color(hexARGB: 0xFFFF5252)

    static let bgGradient = LinearGradient(
        colors: [cyberBgTop, cyberBgMid, cyberBgBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let cardBorderGradient = LinearGradient(
        colors: [cyberCyan.opacity(0.55), cyberPurple.opacity(0.25), .clear],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gaugeGradient = AngularGradient(
        colors: [cyberCyan, cyberPurple, cyberGold, cyberGreen, cyberCyan],
        center: .center
    )

    static let cyanGlowGradient = LinearGradient(
        colors: [cyberCyan, cyberIceBlue],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let cardFillGradient = LinearGradient(
        colors: [cyberCardBg.opacity(0.85), cyberCardSoft.opacity(0.75)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardCornerRadius: CGFloat = 16
    static let chipCornerRadius: CGFloat = 6

    static let displayFont = Font.system(.headline, design: .serif).weight(.heavy)
    static let monoFont = Font.system(.footnote, design: .monospaced)
    static let monoFontSmall = Font.system(.caption2, design: .monospaced)
}

// MARK: - Glow Modifier

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity * 0.7), radius: radius * 0.7)
    }
}

extension View {
    func cyberGlow(_ color: Color = CyberTheme.cyberPurple, radius: CGFloat = 12, opacity: Double = 0.5) -> some View {
        modifier(GlowModifier(color: color, radius: radius, opacity: opacity))
    }
}

// MARK: - Cyber Card (glassmorphism)

struct CyberCard<Content: View>: View {
    var borderColor: Color? = nil
    let content: () -> Content

    init(borderColor: Color? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.borderColor = borderColor
        self.content = content
    }

    var body: some View {
        content()
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: CyberTheme.cardCornerRadius, style: .continuous)
                    .fill(CyberTheme.cardFillGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: CyberTheme.cardCornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [borderColor ?? CyberTheme.cyberCyan, CyberTheme.cyberPurple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: CyberTheme.cyberPurple.opacity(0.12), radius: 8, x: 0, y: 0)
    }
}

// MARK: - Haptic Feedback

enum Haptics {
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

// MARK: - Color Hex Init (ARGB format)

extension Color {
    init(hexARGB: UInt32) {
        let a = Double((hexARGB >> 24) & 0xFF) / 255.0
        let r = Double((hexARGB >> 16) & 0xFF) / 255.0
        let g = Double((hexARGB >> 8) & 0xFF) / 255.0
        let b = Double(hexARGB & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}


