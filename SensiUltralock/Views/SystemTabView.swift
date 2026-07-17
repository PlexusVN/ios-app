import SwiftUI

struct SystemTabView: View {
    @StateObject private var perf = PerformanceMonitor()
    @State private var showAdvanced = false

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                deviceInfoCard
                systemSpecsCard
                performanceCard
                storageCard
                networkCard
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(CyberGridBackground().ignoresSafeArea())
        .onDisappear { perf.cleanup() }
    }

    // MARK: - Device Info
    private var deviceInfoCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 12) {
                CyberSectionHeader(title: "📱 THIẾT BỊ", accent: CyberTheme.cyberCyan)
                sysRow(label: "Tên máy", value: SystemInfo.deviceName)
                sysRow(label: "Dòng máy", value: SystemInfo.displayName)
                sysRow(label: "Model", value: SystemInfo.identifier)
                sysRow(label: "Hệ điều hành", value: "\(SystemInfo.systemName) \(SystemInfo.systemVersion)")
            }
        }
    }

    // MARK: - System Specs
    private var systemSpecsCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 12) {
                CyberSectionHeader(title: "⚙️ THÔNG SỐ HỆ THỐNG", accent: CyberTheme.cyberPurple)
                sysRow(label: "CPU", value: "\(SystemInfo.cpuArch) · \(SystemInfo.cpuCount) cores")
                sysRow(label: "RAM", value: SystemInfo.physicalMemory)
                sysRow(label: "Màn hình", value: "\(SystemInfo.screenResolution) @\(SystemInfo.screenScale)")

                HStack {
                    Text("TẦN SỐ QUÉT")
                        .font(CyberTheme.monoFontSmall)
                        .foregroundStyle(CyberTheme.textSecondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(SystemInfo.isHighRefreshRate ? CyberTheme.cyberGreen : CyberTheme.cyberCyan)
                            .frame(width: 6, height: 6)
                        Text("\(Int(SystemInfo.refreshRate)) Hz")
                            .font(CyberTheme.monoFont.weight(.bold))
                            .foregroundStyle(SystemInfo.isHighRefreshRate ? CyberTheme.cyberGreen : CyberTheme.cyberCyan)
                    }
                }
                .padding(10)
                .background(CyberTheme.darkBorder.opacity(0.4))
                .cornerRadius(8)
            }
        }
    }

    // MARK: - Performance
    private var performanceCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 12) {
                CyberSectionHeader(title: "📊 HIỆU NĂNG", accent: CyberTheme.cyberGreen)

                HStack(spacing: 8) {
                    perfGauge(label: "FPS", value: "\(Int(perf.fps))", color: CyberTheme.cyberGreen)
                    perfGauge(label: "CPU", value: String(format: "%.1f%%", perf.cpuUsage), color: CyberTheme.cyberPurple)
                    perfGauge(label: "RAM", value: perf.memoryUsed, color: CyberTheme.cyberCyan)
                }

                Button(action: { withAnimation { showAdvanced.toggle() } }) {
                    HStack {
                        Text(showAdvanced ? "ẨN" : "CHI TIẾT")
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.cyberCyan)
                        Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                            .font(.system(size: 8))
                            .foregroundStyle(CyberTheme.cyberCyan)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(CyberTheme.cyberCyan.opacity(0.1))
                    .cornerRadius(6)
                }
                .buttonStyle(.plain)

                if showAdvanced {
                    VStack(spacing: 6) {
                        sysRow(label: "CPU Active", value: "\(SystemInfo.cpuActive) cores")
                        sysRow(label: "Battery", value: batteryText)
                        sysRow(label: "Trạng thái pin", value: SystemInfo.batteryState)
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    // MARK: - Storage
    private var storageCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 12) {
                CyberSectionHeader(title: "💾 BỘ NHỚ TRONG", accent: CyberTheme.cyberIceBlue)
                sysRow(label: "Tổng dung lượng", value: SystemInfo.diskTotal)
                sysRow(label: "Còn trống", value: SystemInfo.diskFree)

                GeometryReader { geo in
                    let total = parseGB(SystemInfo.diskTotal)
                    let free = parseGB(SystemInfo.diskFree)
                    let used = max(0, total - free)
                    let ratio = total > 0 ? used / total : 0

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(CyberTheme.darkBorder)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(CyberTheme.cyanGlowGradient)
                            .frame(width: geo.size.width * CGFloat(ratio), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }

    // MARK: - Network
    private var networkCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 12) {
                CyberSectionHeader(title: "🌐 MẠNG", accent: CyberTheme.cyberCyan)
                sysRow(label: "Loại mạng", value: SystemInfo.networkType)
                sysRow(label: "Địa chỉ IP", value: SystemInfo.currentIP)
            }
        }
    }

    // MARK: - Helpers

    private var batteryText: String {
        let l = SystemInfo.batteryLevel
        return l < 0 ? "N/A" : "\(l)%"
    }

    private func sysRow(label: String, value: String) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(CyberTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(CyberTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(8)
        .background(CyberTheme.darkBorder.opacity(0.3))
        .cornerRadius(6)
    }

    private func perfGauge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .black, design: .monospaced))
                .foregroundStyle(color)
                .cyberGlow(color, radius: 3, opacity: 0.3)
            Text(label)
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .foregroundStyle(CyberTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(CyberTheme.darkBorder.opacity(0.3))
        .cornerRadius(6)
    }

    private func parseGB(_ s: String) -> Double {
        let clean = s.replacingOccurrences(of: " GB", with: "").replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0
    }
}
