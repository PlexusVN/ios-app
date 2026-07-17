import SwiftUI

struct OptimizerView: View {
    @ObservedObject var viewModel: AppViewModel

    private var basicFeatures: [ModFeature] { Array(viewModel.allFeatures.prefix(5)) }
    private var proFeatures: [ModFeature] { Array(viewModel.allFeatures[5..<8]) }
    private var vipFeatures: [ModFeature] { Array(viewModel.allFeatures.suffix(2)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                hudHeader
                basicSection
                proSection
                vipSection
                tunerSection
                HeartbeatBar()
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(CyberGridBackground().ignoresSafeArea())
    }

    // MARK: - HUD Header

    private var hudHeader: some View {
        CyberCard {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    TierBadge(tier: viewModel.currentTier)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sensitivity:")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(CyberTheme.textSecondary)
                        Text("x\(String(format: "%.1f", viewModel.dpiFactor)) (DPI Boost)")
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.cyberCyan)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Active patches:")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundStyle(CyberTheme.textSecondary)
                        Text("\(viewModel.activeCount) / \(viewModel.totalCount) Active")
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.cyberGreen)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CyberGauge(
                    percent: viewModel.optimizationPercent,
                    activeCount: viewModel.activeCount,
                    total: viewModel.totalCount
                )
            }
        }
    }

    // MARK: - Basic Section

    private var basicSection: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 10) {
                CyberSectionHeader(title: "TÍNH NĂNG THƯỜNG", accent: CyberTheme.cyberGreen, badge: "BASIC")
                ForEach(basicFeatures) { feature in
                    CyberFeatureToggle(
                        feature: feature,
                        isOn: viewModel.isFeatureOn(feature),
                        locked: false
                    ) { viewModel.toggleFeature(feature) }
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
            VStack(alignment: .leading, spacing: 10) {
                CyberSectionHeader(title: "TÍNH NĂNG CAO CẤP", accent: CyberTheme.cyberPurple, badge: "PRO")
                ForEach(proFeatures) { feature in
                    let locked = !viewModel.isProOrHigher
                    CyberFeatureToggle(
                        feature: feature,
                        isOn: viewModel.isFeatureOn(feature),
                        locked: locked
                    ) { viewModel.toggleFeature(feature) }
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
            VStack(alignment: .leading, spacing: 10) {
                CyberSectionHeader(title: "TÍNH NĂNG THƯỢNG HẠNG", accent: CyberTheme.cyberGold, badge: "VIP")
                ForEach(vipFeatures) { feature in
                    let locked = !viewModel.isVIP
                    CyberFeatureToggle(
                        feature: feature,
                        isOn: viewModel.isFeatureOn(feature),
                        locked: locked
                    ) { viewModel.toggleFeature(feature) }
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
            VStack(alignment: .leading, spacing: 12) {
                CyberSectionHeader(title: "ADVANCED TUNER HUD", accent: CyberTheme.cyberCyan, badge: "VIP")

                if viewModel.isVIP {
                    tunerContent
                } else {
                    tunerLockedOverlay
                }
            }
        }
    }

    private var tunerContent: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("TOUCH SENSITIVITY")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(CyberTheme.textSecondary)
                    Spacer()
                    Text(String(format: "%.1fx", viewModel.dpiFactor))
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(CyberTheme.cyberGreen)
                }
                Slider(value: $viewModel.dpiFactor, in: 1.0...10.0, step: 0.1)
                    .tint(CyberTheme.cyberCyan)
                    .onChange(of: viewModel.dpiFactor) { _ in viewModel.saveTunerDPI() }
            }

            Divider().overlay(CyberTheme.textSecondary.opacity(0.2))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("RECOIL STABILIZATION")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(CyberTheme.textSecondary)
                    Spacer()
                    Text("\(Int(viewModel.recoilReduction))%")
                        .font(.system(.caption, design: .monospaced).weight(.bold))
                        .foregroundStyle(CyberTheme.cyberGreen)
                }
                Slider(value: $viewModel.recoilReduction, in: 20...100, step: 1)
                    .tint(CyberTheme.cyberGreen)
                    .onChange(of: viewModel.recoilReduction) { _ in viewModel.saveTunerRecoil() }
            }

            Divider().overlay(CyberTheme.textSecondary.opacity(0.2))

            VStack(alignment: .leading, spacing: 6) {
                Text("TOUCH RESPONSE")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(CyberTheme.textSecondary)
                HStack(spacing: 8) {
                    ForEach([1, 2, 4, 8], id: \.self) { ms in
                        LatencyChip(label: "\(ms)ms", isSelected: viewModel.responseMs == ms) {
                            viewModel.responseMs = ms
                            viewModel.saveTunerResponse()
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
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundStyle(CyberTheme.textPrimary)
                    .tracking(2)
                Text("Tính năng chỉnh DPI & Recoil chỉ dành cho VIP.")
                    .font(.caption)
                    .foregroundStyle(CyberTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 170)
    }
}
