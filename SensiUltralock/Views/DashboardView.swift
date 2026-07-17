import SwiftUI

struct DashboardView: View {
    let dim: ViewDimensions
    let isVip: Bool
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String
    let onLogout: () -> Void

    @State private var selectedTab = 0
    @State private var activeStates: Set<String> = []
    @State private var dpiFactor: Float = 6.8
    @State private var stabilizationLevel: Float = 85
    @State private var responseMs: Int = 1
    @State private var showEffects = true

    private var w: CGFloat { dim.w }
    private var h: CGFloat { dim.h }
    private var scale: CGFloat { dim.scale }
    private var hp: CGFloat { dim.w * 0.045 }
    private var safeTop: CGFloat { dim.safeTop }
    private var safeBottom: CGFloat { dim.safeBottom }

    private let basicFeaturesList: [ModFeature] = [
        ModFeature(id: "SENSITIVITY", name: "SENSIVITY BOOSTER", description: "Nhạy Màn Hình Tối Đa"),
        ModFeature(id: "SCREEN", name: "SCREEN BOOSTER", description: "Buff FPS Siêu Mượt"),
        ModFeature(id: "BUFF_120HZ", name: "BUFF 120HZ SCREEN", description: "Tần Số Quét 120Hz"),
        ModFeature(id: "FEATHER", name: "FEATHER AIM", description: "Nhẹ Tâm Nhắm FF"),
        ModFeature(id: "HEADSHOT", name: "HEADSHOT FIX", description: "Fix Lỗi Nhắm Headshot")
    ]

    private let proFeaturesList: [ModFeature] = [
        ModFeature(id: "AIMLOCK_PRO", name: "AIMLOCK ASSIST PRO", description: "Hỗ Trợ Khóa Tâm Chuyên Nghiệp"),
        ModFeature(id: "AUTO_TRIGGER", name: "AUTO TRIGGER PRO", description: "Tự Động Bắn Siêu Tốc"),
        ModFeature(id: "RECOIL_REDUCTION", name: "RECOIL CONTROL PRO", description: "Ghìn Tâm Giảm Giật Tối Đa")
    ]

    private let vipFeaturesList: [ModFeature] = [
        ModFeature(id: "AIMLOCK", name: "AIMLOCK ULTRA", description: "Khóa Tâm Bám Đầu [VIP]", isVipOnly: true),
        ModFeature(id: "ANCHOR", name: "ANCHOR AIM", description: "Ghìn Tâm Tự Động [VIP]", isVipOnly: true)
    ]

    private var allFeatures: [ModFeature] { basicFeaturesList + proFeaturesList + vipFeaturesList }

    private var activeRatio: Float {
        guard !allFeatures.isEmpty else { return 0 }
        return Float(activeStates.count) / Float(allFeatures.count)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background layers
            CyberBg.ignoresSafeArea()
            AnimatedGridBackground(color: CyberYellow, opacity: 0.05, animate: true)
                .ignoresSafeArea()
            if showEffects {
                FloatingParticles(count: 30, color: CyberYellow, speed: 0.8)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                ScanlineOverlay(opacity: 0.03)
                    .ignoresSafeArea()
            }

            ZStack(alignment: .topTrailing) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        spacer(safeTop + h * 0.008)

                        headerSection
                        spacer(h * 0.014)
                        tabBar
                        spacer(h * 0.012)

                        switch selectedTab {
                        case 0: optimizerTab
                        case 1: SystemTabView(dim: dim)
                        case 2: UserTabView(dim: dim, keyType: keyType, licenseKey: licenseKey, expiresAt: expiresAt, onLogout: onLogout)
                        default: EmptyView()
                        }

                        spacer(safeBottom + h * 0.02)
                    }
                    .frame(minHeight: h + safeTop + safeBottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Effects toggle button
                Button(action: { showEffects.toggle() }) {
                    Image(systemName: showEffects ? "eye.fill" : "eye.slash")
                        .font(.system(size: 10))
                        .foregroundColor(CyberTextSecondary)
                        .padding(6)
                        .background(CyberDarkBg.opacity(0.6))
                        .cornerRadius(6)
                }
                .padding(.trailing, 8)
                .padding(.top, safeTop + h * 0.06)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .onAppear { loadFeatureStates() }
        .onChange(of: activeStates) { _ in saveActiveFeatures(activeStates) }
        .onChange(of: dpiFactor) { _ in saveAdvancedTuner() }
        .onChange(of: stabilizationLevel) { _ in saveAdvancedTuner() }
        .onChange(of: responseMs) { _ in saveAdvancedTuner() }
    }

    private func loadFeatureStates() {
        let saved = loadActiveFeatures()
        if !saved.isEmpty {
            activeStates = saved.filter { id in
                allFeatures.contains { $0.id == id }
            }
        } else {
            initActiveStates()
        }
        loadAdvancedTuner()
    }

    private func saveAdvancedTuner() {
        UserDefaults.standard.set(dpiFactor, forKey: "tuner_dpi")
        UserDefaults.standard.set(stabilizationLevel, forKey: "tuner_stabilization")
        UserDefaults.standard.set(responseMs, forKey: "tuner_response_ms")
    }

    private func loadAdvancedTuner() {
        dpiFactor = UserDefaults.standard.object(forKey: "tuner_dpi") as? Float ?? 6.8
        stabilizationLevel = UserDefaults.standard.object(forKey: "tuner_stabilization") as? Float ?? 85
        responseMs = UserDefaults.standard.object(forKey: "tuner_response_ms") as? Int ?? 1
    }

    private var headerSection: some View {
        VStack(spacing: h * 0.006) {
            GlitchText(
                text: "Sensi Ultralock",
                size: max(22, 34 * scale),
                color: .white,
                glitchColor1: .red,
                glitchColor2: .cyan,
                intensity: 0.15,
                weight: .black
            )
            .shadow(color: CyberYellow.opacity(0.7), radius: w * 0.03)

            Text("GAME OPTIMIZER")
                .font(.system(size: max(9, 10 * scale), design: .monospaced).weight(.bold))
                .foregroundColor(CyberIceYellow.opacity(0.7))
                .customTracking(max(2, 3 * scale))

            Text("FREE FIRE")
                .font(.system(size: max(12, 14 * scale), weight: .heavy))
                .foregroundColor(CyberYellow)
                .customTracking(max(2, 3 * scale))
                .neonGlow(color: CyberYellow, radius: 6, intensity: 0.4)
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "TỐI ƯU", tab: 0, icon: "⚡")
            tabButton(title: "HỆ THỐNG", tab: 1, icon: "🖥")
            tabButton(title: "THÀNH VIÊN", tab: 2, icon: "👤")
        }
        .background(CyberDarkBg)
        .cornerRadius(max(11, 13 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(11, 13 * scale)).stroke(CyberDarkBorder, lineWidth: 1))
        .padding(.horizontal, w * 0.05)
    }

    private func tabButton(title: String, tab: Int, icon: String) -> some View {
        Button(action: { selectedTab = tab }) {
            HStack(spacing: 4) {
                Text(icon).font(.system(size: max(10, 11 * scale)))
                Text(title)
                    .font(.system(size: max(9, 10 * scale), weight: .bold))
            }
            .foregroundColor(selectedTab == tab ? CyberYellow : CyberTextSecondary)
            .customTracking(0.8)
            .frame(maxWidth: .infinity)
            .padding(.vertical, h * 0.014)
            .background(selectedTab == tab ? CyberYellow.opacity(0.15) : Color.clear)
            .cornerRadius(max(11, 13 * scale))
        }
    }

    // MARK: - Tab 0: Optimizer
    private var optimizerTab: some View {
        VStack(spacing: 0) {
            statusHeader
                .neonGlow(color: CyberYellow, radius: 4, intensity: 0.2)
            spacer(h * 0.016)
            featurePanel(
                title: "TÍNH NĂNG THƯỜNG",
                titleColor: CyberYellow,
                features: basicFeaturesList,
                isLocked: false
            )
            spacer(h * 0.014)
            featurePanel(
                title: "TÍNH NĂNG CAO CẤP",
                titleColor: CyberAmber,
                features: proFeaturesList,
                isLocked: keyType != .pro && keyType != .vip,
                lockedBadge: keyType != .pro && keyType != .vip ? "PRO" : nil
            )
            spacer(h * 0.014)
            featurePanel(
                title: "TÍNH NĂNG THƯỢNG HẠNG",
                titleColor: Color(hexARGB: 0xFFFF6B00),
                features: vipFeaturesList,
                isLocked: keyType != .vip,
                lockedBadge: keyType != .vip ? "VIP" : nil,
                borderColor: keyType == .vip ? CyberAmber.opacity(0.8) : nil
            )
            spacer(h * 0.016)
            AdvancedTunerView(dim: dim, keyType: keyType, dpiFactor: $dpiFactor,
                              stabilizationLevel: $stabilizationLevel, responseMs: $responseMs)
            spacer(h * 0.014)
            statusBanner
        }
    }

    private var statusHeader: some View {
        HStack(spacing: w * 0.025) {
            VStack(alignment: .leading, spacing: h * 0.006) {
                HStack(spacing: w * 0.015) {
                    GlitchText(
                        text: "SYSTEM ENGINE",
                        size: max(11, 12 * scale),
                        color: CyberIceYellow,
                        glitchColor1: .red,
                        glitchColor2: .cyan,
                        intensity: 0.1,
                        weight: .heavy
                    )

                    badgeView
                }

                Text("Active patches: \(activeStates.count) / \(allFeatures.count)")
                    .font(.system(size: max(10, 11 * scale)))
                    .foregroundColor(CyberTextSecondary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(CyberGreen)
                        .frame(width: 5, height: 5)
                    Text(String(format: "Sensitivity: x%.1f | DPI: Boosted", dpiFactor))
                        .font(.system(size: max(10, 11 * scale)))
                        .foregroundColor(CyberTextSecondary)
                }
            }

            Spacer()
            CircularGaugeView(ratio: activeRatio)
                .frame(width: min(w * 0.18, 70), height: min(w * 0.18, 70))
        }
        .padding(.horizontal, hp)
        .padding(.vertical, h * 0.012)
    }

    private var badgeView: some View {
        Group {
            switch keyType {
            case .vip:
                Text("VIP PREMIUM")
                    .font(.system(size: max(8, 9 * scale), design: .monospaced).weight(.black))
                    .foregroundColor(Color(hexARGB: 0xFF0C031A))
                    .padding(.horizontal, w * 0.02)
                    .padding(.vertical, h * 0.005)
                    .background(LinearGradient(colors: [CyberVipGoldStart, CyberVipGoldEnd],
                                               startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(max(6, 8 * scale))
                    .overlay(RoundedRectangle(cornerRadius: max(6, 8 * scale)).stroke(Color(hexARGB: 0xFFFFF59D), lineWidth: 1))
                    .neonGlow(color: CyberVipGoldStart, radius: 4, intensity: 0.5)
            case .pro:
                Text("PRO SPECIAL")
                    .font(.system(size: max(8, 9 * scale), design: .monospaced).weight(.black))
                    .foregroundColor(.white)
                    .padding(.horizontal, w * 0.02)
                    .padding(.vertical, h * 0.005)
                    .background(LinearGradient(colors: [CyberProGradStart, CyberProGradEnd],
                                               startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(max(6, 8 * scale))
                    .overlay(RoundedRectangle(cornerRadius: max(6, 8 * scale)).stroke(CyberYellow, lineWidth: 1))
                    .neonGlow(color: CyberAmber, radius: 3, intensity: 0.3)
            case .basic:
                HStack(spacing: w * 0.01) {
                    Circle().fill(CyberYellow).frame(width: max(5, 6 * scale), height: max(5, 6 * scale))
                    Text("FREE BASIC")
                        .font(.system(size: max(8, 8.5 * scale), design: .monospaced).weight(.bold))
                        .foregroundColor(CyberYellow)
                }
                .padding(.horizontal, w * 0.02)
                .padding(.vertical, h * 0.005)
                .background(LinearGradient(colors: [CyberMediumBg, CyberGradientDark],
                                           startPoint: .leading, endPoint: .trailing))
                .cornerRadius(max(6, 8 * scale))
                .overlay(RoundedRectangle(cornerRadius: max(6, 8 * scale)).stroke(CyberYellow.opacity(0.5), lineWidth: 1))
            }
        }
    }

    private var statusBanner: some View {
        HStack(spacing: w * 0.02) {
            PulsingRadar(color: CyberGreen, count: 2, maxRadius: 12)
                .frame(width: 24, height: 24)
            Text("Hệ thống đang hoạt động tối ưu Free Fire !")
                .font(.system(size: max(10, 11 * scale), design: .monospaced).weight(.bold))
                .foregroundColor(CyberGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(h * 0.016)
        .background(CyberDarkBg.opacity(0.8))
        .cornerRadius(max(12, 14 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(12, 14 * scale)).stroke(
            LinearGradient(colors: [CyberGreen.opacity(0.5), CyberDarkBorder], startPoint: .leading, endPoint: .trailing), lineWidth: 1))
        .padding(.horizontal, hp)
        .neonGlow(color: CyberGreen, radius: 3, intensity: 0.2)
    }

    // MARK: - Feature Panel
    private func featurePanel(title: String, titleColor: Color, features: [ModFeature],
                                isLocked: Bool, lockedBadge: String? = nil,
                                borderColor: Color? = nil) -> some View {
        VStack(alignment: .leading, spacing: h * 0.012) {
            HStack {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(titleColor)
                        .frame(width: 3, height: max(14, 16 * scale))
                    Text(title)
                        .font(.system(size: max(11, 13 * scale), weight: .black))
                        .foregroundColor(titleColor)
                }
                Spacer()
                if let badge = lockedBadge {
                    Text(badge)
                        .font(.system(size: max(7, 8 * scale), weight: .black))
                        .foregroundColor(.red)
                        .padding(.horizontal, w * 0.015)
                        .padding(.vertical, h * 0.003)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(max(5, 6 * scale))
                        .overlay(RoundedRectangle(cornerRadius: max(5, 6 * scale)).stroke(Color.red.opacity(0.5), lineWidth: 1))
                }
            }

            ForEach(features) { feature in
                let locked = isLocked || (feature.isVipOnly && keyType != .vip)
                FeatureCardView(
                    feature: feature,
                    isChecked: activeStates.contains(feature.id),
                    isLocked: locked
                ) { active in
                    if locked {
                        ToastManager.shared.show("Tính năng bị khóa! Vui lòng sử dụng mã kích hoạt cấp cao hơn để mở.", type: .warning)
                        return
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if active {
                            activeStates.insert(feature.id)
                            ToastManager.shared.show("Đã tối ưu hóa: \(feature.name)!", type: .success)
                        } else {
                            activeStates.remove(feature.id)
                            ToastManager.shared.show("Đã hủy kích hoạt: \(feature.name)!", type: .info)
                        }
                    }
                }
            }
        }
        .padding(hp)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(
            LinearGradient(colors: [(borderColor ?? titleColor).opacity(0.6), CyberDarkBorder], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2))
        .shadow(color: (borderColor ?? titleColor).opacity(0.1), radius: w * 0.02)
        .padding(.horizontal, hp)
    }

    private func spacer(_ height: CGFloat) -> some View {
        Color.clear.frame(height: height)
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
}
