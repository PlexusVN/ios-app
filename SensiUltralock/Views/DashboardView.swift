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
            let w = geometry.size.width
            let h = geometry.size.height
            let scale = min(max(w / 375, 0.75), 1.5)
            let hp = w * 0.055

            ZStack {
                Canvas { context, size in
                    let gridSpacing: CGFloat = max(28, w * 0.11)
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
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: h * 0.02)

                        Text("GAME OPTIMIZER")
                            .font(.system(size: max(10, 11 * scale), design: .monospaced).weight(.bold))
                            .foregroundColor(CyberIceYellow.opacity(0.7))
                            .kerning(max(2, 4 * scale))
                            .shadow(color: CyberYellowGlow, radius: w * 0.02)

                        Text("Sensi Ultralock")
                            .font(.custom("Georgia", size: max(24, 38 * scale)))
                            .italic()
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: CyberYellow.opacity(0.85), radius: w * 0.04)

                        Text("FREE FIRE")
                            .font(.system(size: max(13, 16 * scale), weight: .heavy))
                            .foregroundColor(CyberYellow)
                            .kerning(max(2, 3 * scale))
                            .shadow(color: CyberYellowGlow, radius: w * 0.025)

                        Spacer(minLength: h * 0.02)

                        HStack(spacing: 0) {
                            Button(action: { selectedTab = 0 }) {
                                Text("⚡ TỐI ƯU HỆ THỐNG")
                                    .font(.system(size: max(10, 11 * scale), weight: .bold))
                                    .foregroundColor(selectedTab == 0 ? CyberYellow : CyberTextSecondary)
                                    .kerning(1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, h * 0.016)
                                    .background(selectedTab == 0 ? CyberYellow.opacity(0.15) : Color.clear)
                                    .cornerRadius(max(11, 14 * scale))
                            }
                            Button(action: { selectedTab = 1 }) {
                                Text("👤 THÀNH VIÊN")
                                    .font(.system(size: max(10, 11 * scale), weight: .bold))
                                    .foregroundColor(selectedTab == 1 ? CyberYellow : CyberTextSecondary)
                                    .kerning(1)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, h * 0.016)
                                    .background(selectedTab == 1 ? CyberYellow.opacity(0.15) : Color.clear)
                                    .cornerRadius(max(11, 14 * scale))
                            }
                        }
                        .background(CyberDarkBg)
                        .cornerRadius(max(11, 14 * scale))
                        .overlay(RoundedRectangle(cornerRadius: max(11, 14 * scale)).stroke(CyberDarkBorder, lineWidth: 1))
                        .padding(.horizontal, w * 0.055)

                        Spacer(minLength: h * 0.015)

                        if selectedTab == 0 {
                            optimizerTab(w: w, h: h, scale: scale, hp: hp)
                        } else {
                            userTab(w: w, h: h, scale: scale, hp: hp)
                        }

                        Spacer(minLength: h * 0.04)
                    }
                    .frame(minHeight: h)
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .preferredColorScheme(.dark)
            .onAppear { initActiveStates() }
        }
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

    private func optimizerTab(w: CGFloat, h: CGFloat, scale: CGFloat, hp: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: w * 0.03) {
                VStack(alignment: .leading, spacing: h * 0.008) {
                    HStack(spacing: w * 0.02) {
                        Text("SYSTEM ENGINE")
                            .font(.system(size: max(11, 12 * scale), weight: .heavy))
                            .foregroundColor(CyberIceYellow)
                            .kerning(1)

                        switch keyType {
                        case .vip:
                            Text("👑 VIP PREMIUM")
                                .font(.system(size: max(9, 10 * scale), design: .monospaced).weight(.black))
                                .foregroundColor(Color(hexARGB: 0xFF0C031A))
                                .padding(.horizontal, w * 0.025)
                                .padding(.vertical, h * 0.007)
                                .background(LinearGradient(colors: [CyberVipGoldStart, CyberVipGoldEnd],
                                                           startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(max(8, 10 * scale))
                                .overlay(RoundedRectangle(cornerRadius: max(8, 10 * scale)).stroke(Color(hexARGB: 0xFFFFF59D), lineWidth: 1.5))
                        case .pro:
                            Text("⚡ PRO SPECIAL")
                                .font(.system(size: max(9, 10 * scale), design: .monospaced).weight(.black))
                                .foregroundColor(.white)
                                .padding(.horizontal, w * 0.025)
                                .padding(.vertical, h * 0.007)
                                .background(LinearGradient(colors: [CyberProGradStart, CyberProGradEnd],
                                                           startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(max(8, 10 * scale))
                                .overlay(RoundedRectangle(cornerRadius: max(8, 10 * scale)).stroke(CyberYellow, lineWidth: 1.5))
                        case .basic:
                            HStack(spacing: w * 0.015) {
                                Circle().fill(CyberYellow).frame(width: max(6, 8 * scale), height: max(6, 8 * scale))
                                Text("FREE BASIC")
                                    .font(.system(size: max(9, 9.5 * scale), design: .monospaced).weight(.bold))
                                    .foregroundColor(CyberYellow)
                            }
                            .padding(.horizontal, w * 0.025)
                            .padding(.vertical, h * 0.007)
                            .background(LinearGradient(colors: [CyberMediumBg, CyberGradientDark],
                                                       startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(max(8, 10 * scale))
                            .overlay(RoundedRectangle(cornerRadius: max(8, 10 * scale)).stroke(CyberYellow.opacity(0.5), lineWidth: 1.5))
                        }
                    }

                    Text("Active patches: \(activeStates.count) / \(allFeatures.count)")
                        .font(.system(size: max(11, 13 * scale))).foregroundColor(CyberTextSecondary)
                    Text(String(format: "Sensitivity: x%.1f (DPI Boost)", dpiFactor))
                        .font(.system(size: max(11, 13 * scale))).foregroundColor(CyberTextSecondary)

                    Text("Refresh rate output: \(fpsConfig.text)")
                        .font(.system(size: max(11, 13 * scale), weight: .medium)).foregroundColor(fpsConfig.color)
                }

                Spacer()
                CircularGaugeView(ratio: activeRatio)
                    .frame(width: min(w * 0.2, 80), height: min(w * 0.2, 80))
            }
            .padding(.horizontal, hp)

            Spacer(minLength: h * 0.02)

            featurePanel(title: "🔰 TÍNH NĂNG THƯỜNG [BASIC]", titleColor: CyberYellow,
                         features: basicFeaturesList, isLocked: false, w: w, h: h, scale: scale, hp: hp)

            Spacer(minLength: h * 0.02)

            let isProLocked = keyType != .pro && keyType != .vip
            featurePanel(title: "⚡ TÍNH NĂNG CAO CẤP [PRO]", titleColor: isProLocked ? CyberYellow : CyberYellow,
                         features: proFeaturesList, isLocked: isProLocked,
                         lockedBadge: isProLocked ? "🔒 LOCK" : nil, w: w, h: h, scale: scale, hp: hp)

            Spacer(minLength: h * 0.02)

            let isVipLocked = keyType != .vip
            featurePanel(title: "👑 TÍNH NĂNG THƯỢNG HẠNG [VIP]", titleColor: isVipLocked ? CyberYellow : CyberAmber,
                         features: vipFeaturesList, isLocked: isVipLocked,
                         lockedBadge: isVipLocked ? "🔒 LOCK" : nil,
                         unlockedBadge: "ACTIVE",
                         borderColor: isVipLocked ? CyberLockedColor.opacity(0.4) : CyberAmber.opacity(0.8),
                         w: w, h: h, scale: scale, hp: hp)

            Spacer(minLength: h * 0.02)

            AdvancedTunerView(keyType: keyType, dpiFactor: $dpiFactor,
                              stabilizationLevel: $stabilizationLevel, responseMs: $responseMs, w: w, h: h, scale: scale, hp: hp)

            Spacer(minLength: h * 0.02)

            HStack(spacing: w * 0.025) {
                Circle().fill(CyberGreen).frame(width: max(6, 8 * scale), height: max(6, 8 * scale))
                Text("Hệ thống đang hoạt động tối ưu mượt Free Fire !")
                    .font(.system(size: max(11, 12 * scale), design: .monospaced).weight(.bold))
                    .foregroundColor(CyberGreen)
            }
            .frame(maxWidth: .infinity)
            .padding(h * 0.02)
            .background(CyberDarkBg.opacity(0.8))
            .cornerRadius(max(12, 16 * scale))
            .overlay(RoundedRectangle(cornerRadius: max(12, 16 * scale)).stroke(CyberYellow.opacity(0.3), lineWidth: 1))
            .padding(.horizontal, hp)
        }
    }

    // MARK: - Feature Panel Builder

    private func featurePanel(title: String, titleColor: Color, features: [ModFeature],
                              isLocked: Bool, lockedBadge: String? = nil,
                              unlockedBadge: String? = nil, borderColor: Color? = nil,
                              w: CGFloat, h: CGFloat, scale: CGFloat, hp: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: h * 0.015) {
            HStack {
                Text(title)
                    .font(.system(size: max(12, 14 * scale), weight: .black))
                    .foregroundColor(titleColor)
                    .shadow(color: titleColor.opacity(0.4), radius: w * 0.01)
                Spacer()
                if let badge = lockedBadge {
                    Text(badge)
                        .font(.system(size: max(7, 8 * scale), weight: .black)).foregroundColor(.red)
                        .padding(.horizontal, w * 0.015).padding(.vertical, h * 0.003)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(max(5, 6 * scale))
                        .overlay(RoundedRectangle(cornerRadius: max(5, 6 * scale)).stroke(Color.red.opacity(0.6), lineWidth: 1))
                } else if let badge = unlockedBadge {
                    Text(badge)
                        .font(.system(size: max(7, 8 * scale), weight: .black)).foregroundColor(CyberAmber)
                        .padding(.horizontal, w * 0.015).padding(.vertical, h * 0.003)
                        .background(CyberAmber.opacity(0.2))
                        .cornerRadius(max(5, 6 * scale))
                        .overlay(RoundedRectangle(cornerRadius: max(5, 6 * scale)).stroke(CyberAmber, lineWidth: 1))
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
        .padding(hp)
        .background(CyberCardBg)
        .cornerRadius(max(15, 20 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 20 * scale)).stroke(borderColor ?? CyberDarkBorder, lineWidth: 1.2))
        .shadow(color: (borderColor ?? CyberYellow).opacity(0.1), radius: w * 0.02)
        .padding(.horizontal, hp)
    }

    private func userTab(w: CGFloat, h: CGFloat, scale: CGFloat, hp: CGFloat) -> some View {
        UserTabView(keyType: keyType, licenseKey: licenseKey, expiresAt: expiresAt, onLogout: onLogout, w: w, h: h, scale: scale, hp: hp)
    }
}
