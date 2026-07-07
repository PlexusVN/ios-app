import SwiftUI

struct DashboardView: View {
    let isVip: Bool
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String
    let onLogout: () -> Void

    @State private var selectedTab = 0

    let basicFeaturesList: [ModFeature] = [
        ModFeature(id: "SENSITIVITY", name: "SENSIVITY BOOSTER", description: "Nhạy Màn Hình Tối Đa"),
        ModFeature(id: "SCREEN", name: "SCREEN BOOSTER", description: "Buff FPS Siêu Mượt"),
        ModFeature(id: "BUFF_120HZ", name: "BUFF 120HZ SCREEN", description: "Tần Số Quét 120Hz Cao Cấp"),
        ModFeature(id: "FEATHER", name: "FEATHER AIM", description: "Nhẹ Tâm Nhắm FF"),
        ModFeature(id: "HEADSHOT", name: "HEADSHOT FIX", description: "Fix Lỗi Nhắm Headshot")
    ]

    let proFeaturesList: [ModFeature] = [
        ModFeature(id: "AIMLOCK_PRO", name: "AIMLOCK ASSIST PRO ⚡", description: "Hỗ Trợ Khóa Tâm Chuyên Nghiệp"),
        ModFeature(id: "AUTO_TRIGGER", name: "AUTO TRIGGER PRO ⚡", description: "Tự Động Bắn Siêu Tốc Pro"),
        ModFeature(id: "RECOIL_REDUCTION", name: "RECOIL CONTROL PRO ⚡", description: "Ghìm Tâm Giảm Giật Tối Đa")
    ]

    let vipFeaturesList: [ModFeature] = [
        ModFeature(id: "AIMLOCK", name: "AIMLOCK ULTRA 👑", description: "Khóa Tâm Bám Đầu [VIP Only]", isVipOnly: true),
        ModFeature(id: "ANCHOR", name: "ANCHOR AIM 👑", description: "Ghìm Tâm Tự Động [VIP Only]", isVipOnly: true)
    ]

    @State private var activeStates: Set<String> = []
    @State private var dpiFactor: Float = 6.8
    @State private var stabilizationLevel: Float = 85
    @State private var responseMs: Int = 1

    private var allFeatures: [ModFeature] {
        basicFeaturesList + proFeaturesList + vipFeaturesList
    }

    private var activeRatio: Float {
        guard !allFeatures.isEmpty else { return 0 }
        return Float(activeStates.count) / Float(allFeatures.count)
    }

    private var fpsConfig: (text: String, color: Color) {
        if activeStates.contains("SCREEN") {
            return ("144 FPS / 144Hz ⚡", CyberGreen)
        } else if activeStates.contains("BUFF_120HZ") {
            return ("120 FPS / 120Hz ✨", CyberGreen)
        }
        return ("60 FPS / 60Hz", CyberIceYellow)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Grid background
                Canvas { context, size in
                    let gridSpacing: CGFloat = 40
                    for x in stride(from: 0, through: size.width, by: gridSpacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(path, with: .color(CyberYellow.opacity(0.05)), lineWidth: 1)
                    }
                    for y in stride(from: 0, through: size.height, by: gridSpacing) {
                        var path = Path()
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: size.width, y: y))
                        context.stroke(path, with: .color(CyberYellow.opacity(0.05)), lineWidth: 1)
                    }
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 16)

                        Text("GAME OPTIMIZER")
                            .font(.system(size: 11, design: .monospaced).weight(.bold))
                            .foregroundColor(CyberIceYellow.opacity(0.7))
                            .kerning(4)
                            .shadow(color: CyberYellowGlow, radius: 8)

                        Text("Sensi Ultralock")
                            .font(.custom("Georgia", size: 38))
                            .italic()
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: CyberYellow.opacity(0.85), radius: 15)

                        Text("FREE FIRE")
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundColor(CyberYellow)
                            .kerning(3)
                            .shadow(color: CyberYellowGlow, radius: 10)

                        Spacer().frame(height: 16)

                        // Tab Switcher
                        HStack(spacing: 0) {
                            Button(action: { selectedTab = 0 }) {
                                Text("⚡ TỐI ƯU HỆ THỐNG")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(selectedTab == 0 ? CyberYellow : CyberTextSecondary)
                                    .kerning(1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedTab == 0 ? CyberYellow.opacity(0.15) : Color.clear)
                                    .cornerRadius(14)
                            }
                            Button(action: { selectedTab = 1 }) {
                                Text("👤 THÀNH VIÊN")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(selectedTab == 1 ? CyberYellow : CyberTextSecondary)
                                    .kerning(1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedTab == 1 ? CyberYellow.opacity(0.15) : Color.clear)
                                    .cornerRadius(14)
                            }
                        }
                        .background(CyberDarkBg)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(CyberDarkBorder, lineWidth: 1))
                        .padding(.horizontal, 20)

                        Spacer().frame(height: 12)

                        if selectedTab == 0 {
                            optimizerTab
                        } else {
                            userTab
                        }
                        Spacer().frame(height: 32)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { initActiveStates() }
    }

    private func initActiveStates() {
        for f in basicFeaturesList where f.defaultActive { activeStates.insert(f.id) }
        if keyType == .pro || keyType == .vip {
            for f in proFeaturesList where f.defaultActive { activeStates.insert(f.id) }
        }
        if keyType == .vip {
            for f in vipFeaturesList where f.defaultActive { activeStates.insert(f.id) }
        }
    }

    // MARK: - Tab 0: Optimizer

    private var optimizerTab: some View {
        VStack(spacing: 0) {
            // System Engine + Circular Gauge
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text("SYSTEM ENGINE")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(CyberIceYellow)
                            .kerning(1)

                        switch keyType {
                        case .vip:
                            Text("👑 VIP PREMIUM")
                                .font(.system(size: 10, design: .monospaced).weight(.black))
                                .foregroundColor(Color(hexARGB: 0xFF0C031A))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(LinearGradient(colors: [CyberVipGoldStart, CyberVipGoldEnd],
                                                           startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hexARGB: 0xFFFFF59D), lineWidth: 1.5))
                        case .pro:
                            Text("⚡ PRO SPECIAL")
                                .font(.system(size: 10, design: .monospaced).weight(.black))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(LinearGradient(colors: [CyberProGradStart, CyberProGradEnd],
                                                           startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(CyberYellow, lineWidth: 1.5))
                        case .basic:
                            HStack(spacing: 6) {
                                Circle().fill(CyberYellow).frame(width: 8, height: 8)
                                Text("FREE BASIC")
                                    .font(.system(size: 9.5, design: .monospaced).weight(.bold))
                                    .foregroundColor(CyberYellow)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(LinearGradient(colors: [CyberMediumBg, CyberGradientDark],
                                                       startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(CyberYellow.opacity(0.5), lineWidth: 1.5))
                        }
                    }

                    Text("Active patches: \(activeStates.count) / \(allFeatures.count)")
                        .font(.system(size: 13)).foregroundColor(CyberTextSecondary)
                    Text(String(format: "Sensitivity: x%.1f (DPI Boost)", dpiFactor))
                        .font(.system(size: 13)).foregroundColor(CyberTextSecondary)

                    Text("Refresh rate output: \(fpsConfig.text)")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(fpsConfig.color)
                }

                Spacer()
                CircularGaugeView(ratio: activeRatio)
                    .frame(width: 80, height: 80)
            }
            .padding(.horizontal, 28)

            Spacer().frame(height: 16)

            featurePanel(title: "🔰 TÍNH NĂNG THƯỜNG [BASIC]", titleColor: CyberYellow,
                         features: basicFeaturesList, isLocked: false)

            Spacer().frame(height: 16)

            let isProLocked = keyType != .pro && keyType != .vip
            featurePanel(title: "⚡ TÍNH NĂNG CAO CẤP [PRO]", titleColor: isProLocked ? CyberYellow : CyberYellow,
                         features: proFeaturesList, isLocked: isProLocked,
                         lockedBadge: isProLocked ? "🔒 LOCK" : nil)

            Spacer().frame(height: 16)

            let isVipLocked = keyType != .vip
            featurePanel(title: "👑 TÍNH NĂNG THƯỢNG HẠNG [VIP]", titleColor: isVipLocked ? CyberYellow : CyberAmber,
                         features: vipFeaturesList, isLocked: isVipLocked,
                         lockedBadge: isVipLocked ? "🔒 LOCK" : nil,
                         unlockedBadge: "ACTIVE",
                         borderColor: isVipLocked ? CyberLockedColor.opacity(0.4) : CyberAmber.opacity(0.8))

            Spacer().frame(height: 16)

            AdvancedTunerView(keyType: keyType, dpiFactor: $dpiFactor,
                              stabilizationLevel: $stabilizationLevel, responseMs: $responseMs)

            Spacer().frame(height: 16)

            // System Status
            HStack(spacing: 10) {
                Circle().fill(CyberGreen).frame(width: 8, height: 8)
                Text("Hệ thống đang hoạt động tối ưu mượt Free Fire !")
                    .font(.system(size: 12, design: .monospaced).weight(.bold))
                    .foregroundColor(CyberGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(CyberDarkBg.opacity(0.8))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(CyberYellow.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Feature Panel Builder

    private func featurePanel(title: String, titleColor: Color, features: [ModFeature],
                              isLocked: Bool, lockedBadge: String? = nil,
                              unlockedBadge: String? = nil, borderColor: Color? = nil) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(titleColor)
                    .shadow(color: titleColor.opacity(0.4), radius: 4)
                Spacer()
                if let badge = lockedBadge {
                    Text(badge)
                        .font(.system(size: 8, weight: .black)).foregroundColor(.red)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.red.opacity(0.6), lineWidth: 1))
                } else if let badge = unlockedBadge {
                    Text(badge)
                        .font(.system(size: 8, weight: .black)).foregroundColor(CyberAmber)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(CyberAmber.opacity(0.2))
                        .cornerRadius(6)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(CyberAmber, lineWidth: 1))
                }
            }

            ForEach(features) { feature in
                FeatureCardView(
                    feature: feature,
                    isChecked: activeStates.contains(feature.id),
                    isLocked: isLocked || (feature.isVipOnly && keyType != .vip)
                ) { active in
                    if active { activeStates.insert(feature.id) }
                    else { activeStates.remove(feature.id) }
                }
            }
        }
        .padding(16)
        .background(CyberCardBg)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(borderColor ?? CyberDarkBorder, lineWidth: 1.2))
        .shadow(color: (borderColor ?? CyberYellow).opacity(0.1), radius: 8)
        .padding(.horizontal, 20)
    }

    private var userTab: some View {
        UserTabView(keyType: keyType, licenseKey: licenseKey, expiresAt: expiresAt, onLogout: onLogout)
    }
}
