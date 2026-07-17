import SwiftUI
import Combine

struct OptimizerView: View {
    let keyType: KeyType
    @Binding var activeStates: Set<String>
    @Binding var dpiFactor: Double
    @Binding var recoilReduction: Double
    @Binding var responseMs: Int

    private let basicFeatures: [ModFeature] = [
        ModFeature(id: "SENSITIVITY", name: "SENSIVITY BOOSTER", description: "Nhạy Màn Hình Tối Đa"),
        ModFeature(id: "SCREEN", name: "SCREEN BOOSTER", description: "Buff FPS Siêu Mượt"),
        ModFeature(id: "BUFF_120HZ", name: "BUFF 120HZ SCREEN", description: "Tần Số Quét 120Hz"),
        ModFeature(id: "FEATHER", name: "FEATHER AIM", description: "Nhẹ Tâm Nhắm FF"),
        ModFeature(id: "HEADSHOT", name: "HEADSHOT FIX", description: "Fix Lỗi Nhắm Headshot")
    ]

    private let proFeatures: [ModFeature] = [
        ModFeature(id: "AIMLOCK_PRO", name: "AIMLOCK ASSIST PRO", description: "Hỗ Trợ Khóa Tâm Chuyên Nghiệp"),
        ModFeature(id: "AUTO_TRIGGER", name: "AUTO TRIGGER PRO", description: "Tự Động Bắn Siêu Tốc"),
        ModFeature(id: "RECOIL_REDUCTION", name: "RECOIL CONTROL PRO", description: "Ghìn Tâm Giảm Giật Tối Đa")
    ]

    private let vipFeatures: [ModFeature] = [
        ModFeature(id: "AIMLOCK", name: "AIMLOCK ULTRA", description: "Khóa Tâm Bám Đầu [VIP]", isVipOnly: true),
        ModFeature(id: "ANCHOR", name: "ANCHOR AIM", description: "Ghìn Tâm Tự Động [VIP]", isVipOnly: true)
    ]

    private var allFeatures: [ModFeature] { basicFeatures + proFeatures + vipFeatures }
    private var activeRatio: Double {
        guard !allFeatures.isEmpty else { return 0 }
        return Double(activeStates.count) / Double(allFeatures.count) * 100
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                hudHeader
                basicSection
                proSection
                vipSection
                tunerSection
                HeartbeatBar()
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .modifier(HideScrollIndicators())
        .background(CyberGridBackground().ignoresSafeArea())
        .onAppear { loadFeatureStates() }
    }

    // MARK: - HUD Header

    private var hudHeader: some View {
        CyberCard {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    TierBadge(tier: keyType)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sensitivity:")
                            .font(CyberTheme.monoFontSmall)
                            .foregroundStyle(CyberTheme.textSecondary)
                        Text("x\(String(format: "%.1f", dpiFactor)) (DPI Boost)")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.cyberCyan)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active patches:")
                            .font(CyberTheme.monoFontSmall)
                            .foregroundStyle(CyberTheme.textSecondary)
                        Text("\(activeStates.count) / \(allFeatures.count) Active")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.cyberGreen)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CyberGauge(
                    percent: activeRatio,
                    activeCount: activeStates.count,
                    total: allFeatures.count
                )
            }
        }
    }

    // MARK: - Basic Section

    private var basicSection: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 14) {
                CyberSectionHeader(title: "TÍNH NĂNG THƯỜNG", accent: CyberTheme.cyberGreen, badge: "BASIC")
                ForEach(basicFeatures) { feature in
                    CyberFeatureToggle(
                        feature: feature,
                        isOn: activeStates.contains(feature.id),
                        locked: false
                    ) { toggleFeature(feature) }
                    if feature.id != basicFeatures.last?.id {
                        Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                    }
                }
            }
        }
    }

    // MARK: - Pro Section

    private var proSection: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 14) {
                CyberSectionHeader(title: "TÍNH NĂNG CAO CẤP", accent: CyberTheme.cyberPurple, badge: "PRO")
                ForEach(proFeatures) { feature in
                    let locked = keyType != .pro && keyType != .vip
                    CyberFeatureToggle(
                        feature: feature,
                        isOn: activeStates.contains(feature.id),
                        locked: locked
                    ) { toggleFeature(feature) }
                    if feature.id != proFeatures.last?.id {
                        Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                    }
                }
            }
        }
    }

    // MARK: - VIP Section

    private var vipSection: some View {
        CyberCard(borderColor: CyberTheme.cyberGold) {
            VStack(alignment: .leading, spacing: 14) {
                CyberSectionHeader(title: "TÍNH NĂNG THƯỢNG HẠNG", accent: CyberTheme.cyberGold, badge: "VIP")
                ForEach(vipFeatures) { feature in
                    let locked = keyType != .vip
                    CyberFeatureToggle(
                        feature: feature,
                        isOn: activeStates.contains(feature.id),
                        locked: locked
                    ) { toggleFeature(feature) }
                    if feature.id != vipFeatures.last?.id {
                        Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                    }
                }
            }
        }
    }

    // MARK: - Tuner Section

    private var tunerSection: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 16) {
                CyberSectionHeader(title: "ADVANCED TUNER HUD", accent: CyberTheme.cyberCyan, badge: "VIP")

                if keyType == .vip {
                    tunerContent
                } else {
                    tunerLockedOverlay
                }
            }
        }
    }

    private var tunerContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("TOUCH SENSITIVITY")
                        .font(CyberTheme.monoFontSmall)
                        .foregroundStyle(CyberTheme.textSecondary)
                    Spacer()
                    Text(String(format: "%.1fx", dpiFactor))
                        .font(CyberTheme.monoFont.weight(.bold))
                        .foregroundStyle(CyberTheme.cyberGreen)
                }
                Slider(value: $dpiFactor, in: 1.0...10.0, step: 0.1)
                    .tint(CyberTheme.cyberCyan)
                    .onReceive(Just(dpiFactor)) { _ in
                        UserDefaults.standard.set(dpiFactor, forKey: "tuner_dpi")
                    }
            }

            Divider().overlay(CyberTheme.textSecondary.opacity(0.2))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("RECOIL STABILIZATION")
                        .font(CyberTheme.monoFontSmall)
                        .foregroundStyle(CyberTheme.textSecondary)
                    Spacer()
                    Text("\(Int(recoilReduction))%")
                        .font(CyberTheme.monoFont.weight(.bold))
                        .foregroundStyle(CyberTheme.cyberGreen)
                }
                Slider(value: $recoilReduction, in: 20...100, step: 1)
                    .tint(CyberTheme.cyberGreen)
                    .onReceive(Just(recoilReduction)) { _ in
                        UserDefaults.standard.set(recoilReduction, forKey: "tuner_recoil")
                    }
            }

            Divider().overlay(CyberTheme.textSecondary.opacity(0.2))

            VStack(alignment: .leading, spacing: 8) {
                Text("TOUCH RESPONSE")
                    .font(CyberTheme.monoFontSmall)
                    .foregroundStyle(CyberTheme.textSecondary)
                HStack(spacing: 10) {
                    ForEach([1, 2, 4, 8], id: \.self) { ms in
                        LatencyChip(label: "\(ms)ms", isSelected: responseMs == ms) {
                            responseMs = ms
                            UserDefaults.standard.set(ms, forKey: "tuner_response")
                        }
                    }
                }
            }
        }
    }

    private var tunerLockedOverlay: some View {
        ZStack {
            tunerContent
                .blur(radius: 4)
                .disabled(true)
                .overlay(Color.black.opacity(0.45))

            VStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(CyberTheme.dangerRed)
                Text("ADVANCED TUNER HUD")
                    .customTracking(2)
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundStyle(CyberTheme.textPrimary)
                Text("Tính năng chỉnh DPI & Recoil chỉ dành cho VIP.")
                    .font(.caption)
                    .foregroundStyle(CyberTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220)
    }

    // MARK: - Toggle Logic

    private func toggleFeature(_ feature: ModFeature) {
        let locked = feature.isVipOnly && keyType != .vip
        if locked {
            Haptics.error()
            ToastManager.shared.show("Tính năng này chỉ dành cho VIP!", type: .warning)
            return
        }
        Haptics.medium()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if activeStates.contains(feature.id) {
                activeStates.remove(feature.id)
                ToastManager.shared.show("Đã tắt: \(feature.name)", type: .info)
            } else {
                activeStates.insert(feature.id)
                ToastManager.shared.show("Đã bật: \(feature.name)", type: .success)
            }
        }
        saveActiveFeatures(activeStates)
    }

    private func loadFeatureStates() {
        let saved = loadActiveFeatures()
        if !saved.isEmpty {
            activeStates = saved.filter { id in allFeatures.contains { $0.id == id } }
        } else {
            for f in basicFeatures where f.defaultActive { activeStates.insert(f.id) }
        }
        dpiFactor = UserDefaults.standard.object(forKey: "tuner_dpi") as? Double ?? 1.0
        recoilReduction = UserDefaults.standard.object(forKey: "tuner_recoil") as? Double ?? 20.0
        responseMs = UserDefaults.standard.object(forKey: "tuner_response") as? Int ?? 1
    }
}
