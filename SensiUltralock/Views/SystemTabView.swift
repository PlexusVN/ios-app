import SwiftUI

struct SystemTabView: View {
    let dim: ViewDimensions
    @StateObject private var perf = PerformanceMonitor()
    @State private var showAdvanced = false

    private var w: CGFloat { dim.w }
    private var h: CGFloat { dim.h }
    private var scale: CGFloat { dim.scale }
    private var hp: CGFloat { dim.w * 0.045 }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: h * 0.016) {
                deviceInfoCard
                systemSpecsCard
                performanceCard
                storageCard
                networkCard
            }
            .padding(.horizontal, hp)
            .padding(.vertical, h * 0.012)
        }
        .onDisappear { perf.cleanup() }
    }

    // MARK: - Device Info
    private var deviceInfoCard: some View {
        VStack(spacing: h * 0.012) {
            sectionHeader(icon: "📱", title: "THIẾT BỊ", color: CyberYellow)

            VStack(spacing: h * 0.008) {
                sysRow(label: "Tên máy", value: SystemInfo.deviceName, color: .white)
                sysRow(label: "Dòng máy", value: SystemInfo.displayName, color: .white)
                sysRow(label: "Model", value: SystemInfo.identifier, color: CyberTextSecondary)
                sysRow(label: "Hệ điều hành", value: "\(SystemInfo.systemName) \(SystemInfo.systemVersion)", color: .white)
            }
            .padding(.horizontal, hp * 0.5)
            .padding(.vertical, h * 0.008)
        }
        .padding(hp * 0.8)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(LinearGradient(colors: [CyberYellow.opacity(0.6), CyberDarkBorder], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
        .neonGlow(color: CyberYellow, radius: 6, intensity: 0.3)
    }

    // MARK: - System Specs
    private var systemSpecsCard: some View {
        VStack(spacing: h * 0.012) {
            sectionHeader(icon: "⚙️", title: "THÔNG SỐ HỆ THỐNG", color: CyberAmber)

            VStack(spacing: h * 0.008) {
                sysRow(label: "CPU", value: "\(SystemInfo.cpuArch) · \(SystemInfo.cpuCount) cores", color: .white)
                sysRow(label: "RAM", value: SystemInfo.physicalMemory, color: .white)
                sysRow(label: "Màn hình", value: "\(SystemInfo.screenResolution) @\(SystemInfo.screenScale)", color: CyberTextSecondary)
                HStack {
                    Text("TẦN SỐ QUÉT")
                        .font(.system(size: max(9, 10 * scale), weight: .bold))
                        .foregroundColor(CyberTextSecondary)
                        .kerning(0.6)
                    Spacer()
                    HStack(spacing: 4) {
                        Circle()
                            .fill(SystemInfo.isHighRefreshRate ? CyberGreen : CyberYellow)
                            .frame(width: 6, height: 6)
                        Text("\(Int(SystemInfo.refreshRate)) Hz")
                            .font(.system(size: max(11, 12 * scale), weight: .bold, design: .monospaced))
                            .foregroundColor(SystemInfo.isHighRefreshRate ? CyberGreen : CyberYellow)
                    }
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(CyberDarkBg.opacity(0.4))
                .cornerRadius(9)
            }
            .padding(.horizontal, hp * 0.5)
            .padding(.vertical, h * 0.008)
        }
        .padding(hp * 0.8)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(LinearGradient(colors: [CyberAmber.opacity(0.5), CyberDarkBorder], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }

    // MARK: - Performance Monitor
    private var performanceCard: some View {
        VStack(spacing: h * 0.012) {
            sectionHeader(icon: "📊", title: "HIỆU NĂNG THỜI GIAN THỰC", color: CyberGreen)

            VStack(spacing: h * 0.008) {
                HStack {
                    perfGauge(label: "FPS", value: "\(Int(perf.fps))", color: perf.fps > 55 ? CyberGreen : CyberYellow)
                    perfGauge(label: "CPU", value: String(format: "%.1f%%", perf.cpuUsage), color: CyberAmber)
                    perfGauge(label: "RAM", value: perf.memoryUsed, color: CyberIceYellow)
                }

                Button(action: { showAdvanced.toggle() }) {
                    HStack {
                        Text(showAdvanced ? "ẨN CHI TIẾT" : "XEM CHI TIẾT")
                            .font(.system(size: max(8, 9 * scale), weight: .bold))
                            .foregroundColor(CyberYellow)
                        Image(systemName: showAdvanced ? "chevron.up" : "chevron.down")
                            .font(.system(size: 8))
                            .foregroundColor(CyberYellow)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(CyberYellow.opacity(0.1))
                    .cornerRadius(7)
                }

                if showAdvanced {
                    VStack(spacing: h * 0.006) {
                        sysRow(label: "CPU Active", value: "\(SystemInfo.cpuActive) cores", color: CyberTextSecondary)
                        sysRow(label: "Battery", value: batteryText, color: batteryColor)
                        sysRow(label: "Trạng thái pin", value: SystemInfo.batteryState, color: CyberTextSecondary)
                        sysRow(label: "Display Link", value: "Apple ProMotion \(Int(SystemInfo.refreshRate))Hz", color: CyberGreen)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, hp * 0.5)
            .padding(.vertical, h * 0.008)
        }
        .padding(hp * 0.8)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(LinearGradient(colors: [CyberGreen.opacity(0.5), CyberDarkBorder], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }

    private var batteryText: String {
        let l = SystemInfo.batteryLevel
        return l < 0 ? "N/A" : "\(l)%"
    }

    private var batteryColor: Color {
        let l = SystemInfo.batteryLevel
        if l < 0 { return CyberTextSecondary }
        if l > 70 { return CyberGreen }
        if l > 30 { return CyberYellow }
        return .red
    }

    // MARK: - Storage
    private var storageCard: some View {
        VStack(spacing: h * 0.012) {
            sectionHeader(icon: "💾", title: "BỘ NHỚ TRONG", color: CyberIceYellow)

            VStack(spacing: h * 0.008) {
                sysRow(label: "Tổng dung lượng", value: SystemInfo.diskTotal, color: .white)
                sysRow(label: "Còn trống", value: SystemInfo.diskFree, color: CyberGreen)

                GeometryReader { geo in
                    let total = parseGB(SystemInfo.diskTotal)
                    let free = parseGB(SystemInfo.diskFree)
                    let used = max(0, total - free)
                    let ratio = total > 0 ? used / total : 0

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(CyberDarkBorder)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(colors: [CyberYellow, CyberAmber],
                                               startPoint: .leading, endPoint: .trailing)
                            )
                            .frame(width: geo.size.width * CGFloat(ratio), height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 11)
            }
            .padding(.horizontal, hp * 0.5)
            .padding(.vertical, h * 0.008)
        }
        .padding(hp * 0.8)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(LinearGradient(colors: [CyberIceYellow.opacity(0.4), CyberDarkBorder], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1))
    }

    // MARK: - Network
    private var networkCard: some View {
        VStack(spacing: h * 0.012) {
            sectionHeader(icon: "🌐", title: "MẠNG", color: CyberIceYellow)

            VStack(spacing: h * 0.008) {
                sysRow(label: "Loại mạng", value: SystemInfo.networkType, color: .white)
                sysRow(label: "Địa chỉ IP", value: SystemInfo.currentIP, color: CyberTextSecondary)
            }
            .padding(.horizontal, hp * 0.5)
            .padding(.vertical, h * 0.008)
        }
        .padding(hp * 0.8)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(CyberDarkBorder, lineWidth: 1))
    }

    // MARK: - Reusable Components

    private func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: w * 0.025) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: min(w * 0.08, 32), height: min(w * 0.08, 32))
                Text(icon).font(.system(size: max(12, 14 * scale)))
            }
            Text(title)
                .font(.system(size: max(12, 14 * scale), weight: .black))
                .foregroundColor(color)
                .kerning(1.5)
            Spacer()
        }
    }

    private func sysRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Text(label.uppercased())
                .font(.system(size: max(9, 10 * scale), weight: .bold))
                .foregroundColor(CyberTextSecondary)
                .kerning(0.6)
            Spacer()
            Text(value)
                .font(.system(size: max(10, 11 * scale), weight: .semibold, design: .monospaced))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(CyberDarkBg.opacity(0.4))
        .cornerRadius(9)
    }

    private func perfGauge(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: max(14, 16 * scale), weight: .black, design: .monospaced))
                .foregroundColor(color)
                .neonGlow(color: color, radius: 4, intensity: 0.3)
            Text(label)
                .font(.system(size: max(7, 8 * scale), weight: .bold))
                .foregroundColor(CyberTextSecondary)
                .kerning(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(CyberDarkBg.opacity(0.4))
        .cornerRadius(9)
    }

    private func parseGB(_ s: String) -> Double {
        let clean = s.replacingOccurrences(of: " GB", with: "").replacingOccurrences(of: ",", with: ".")
        return Double(clean) ?? 0
    }
}
