import SwiftUI
import UIKit

// MARK: - Custom Neon Toggle Switch

struct CustomToggleView: View {
    let checked: Bool
    let onCheckedChange: (Bool) -> Void

    @State private var thumbOffset: CGFloat = 0
    private let trackWidth: CGFloat = 48
    private let trackHeight: CGFloat = 26
    private let thumbSize: CGFloat = 18
    private let paddingTrack: CGFloat = 4

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: trackHeight / 2)
                .fill(checked ?
                      LinearGradient(colors: [CyberToggleGradStart, CyberToggleGradEnd],
                                     startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [CyberToggleTrack, CyberToggleTrack],
                                       startPoint: .leading, endPoint: .trailing))
                .frame(width: trackWidth, height: trackHeight)
                .overlay(RoundedRectangle(cornerRadius: trackHeight / 2)
                    .stroke(checked ? CyberYellow : CyberDarkBorder, lineWidth: 1))

            Circle()
                .fill(Color.white)
                .frame(width: thumbSize, height: thumbSize)
                .offset(x: thumbOffset)
                .padding(.leading, paddingTrack)
        }
        .frame(width: trackWidth, height: trackHeight)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                onCheckedChange(!checked)
            }
        }
        .onAppear {
            thumbOffset = checked ? trackWidth - thumbSize - paddingTrack * 2 : 0
        }
        .onChange(of: checked) { newValue in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                thumbOffset = newValue ? trackWidth - thumbSize - paddingTrack * 2 : 0
            }
        }
    }
}

// MARK: - Circular Gauge

struct CircularGaugeView: View {
    let ratio: Float
    @State private var animatedProgress: Float = 0

    var body: some View {
        GeometryReader { geometry in
            let gaugeSize = min(geometry.size.width, geometry.size.height)
            let lineW = max(4, gaugeSize * 0.08)
            ZStack {
                Circle()
                    .stroke(CyberDarkBorder, lineWidth: lineW)
                Circle()
                    .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                    .stroke(CyberYellow, style: StrokeStyle(lineWidth: lineW, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animatedProgress)

                VStack(spacing: 0) {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: max(11, gaugeSize * 0.22), weight: .black))
                        .foregroundColor(.white)
                        .shadow(color: CyberYellow, radius: gaugeSize * 0.05)
                    Text("BOOSTED")
                        .font(.system(size: max(6, gaugeSize * 0.1), weight: .bold))
                        .foregroundColor(CyberYellow)
                        .kerning(0.5)
                }
            }
            .frame(width: gaugeSize, height: gaugeSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear { animatedProgress = ratio }
        .onChange(of: ratio) { animatedProgress = $0 }
    }
}

// MARK: - Feature Card

struct FeatureCardView: View {
    let feature: ModFeature
    let isChecked: Bool
    let isLocked: Bool
    let onToggle: (Bool) -> Void

    @State private var animatedBorderColor: Color = CyberDarkBorder

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(feature.name)
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(isLocked ? CyberYellow : .white)
                        .kerning(0.5)

                    if feature.isVipOnly || isLocked {
                        Text(isLocked ? "LOCKED" : "VIP")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(isLocked ? .white : .black)
                            .padding(.horizontal, 4).padding(.vertical, 2)
                            .background(isLocked ? CyberLockedColor : CyberAmber)
                            .cornerRadius(6)
                    }
                }

                HStack(spacing: 6) {
                    if isLocked {
                        Text("🔒 \(feature.description)")
                            .font(.system(size: 11.2, weight: .medium))
                            .foregroundColor(CyberTextSecondary.opacity(0.7))
                    } else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(CyberGreen)
                            .frame(width: 9 * 1.3, height: 9 * 1.3)
                        Text(feature.description)
                            .font(.system(size: 11.2, weight: .medium))
                            .foregroundColor(CyberTextSecondary)
                    }
                }
            }

            Spacer()

            if isLocked {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(CyberLockedColor.opacity(0.3))
                        .frame(width: 48, height: 26)
                        .overlay(RoundedRectangle(cornerRadius: 13)
                            .stroke(CyberLockedColor.opacity(0.5), lineWidth: 1))
                    Text("🔒").font(.system(size: 10))
                }
            } else {
                CustomToggleView(checked: isChecked, onCheckedChange: onToggle)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(isLocked ? CyberDarkBg.opacity(0.6) : CyberDarkBg)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(animatedBorderColor, lineWidth: 1.2))
        .onAppear { updateBorderColor() }
        .onChange(of: isChecked) { _ in updateBorderColor() }
        .onChange(of: isLocked) { _ in updateBorderColor() }
    }

    private func updateBorderColor() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if isLocked { animatedBorderColor = CyberLockedColor.opacity(0.5) }
            else if isChecked { animatedBorderColor = CyberYellow }
            else { animatedBorderColor = CyberDarkBorder }
        }
    }
}

// MARK: - Profile Detail Row

struct ProfileDetailRow: View {
    let label: String
    let value: String
    var copyEnabled: Bool = false
    var textColor: Color = .white

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(CyberTextSecondary)
                    .kerning(0.8)
                Text(value)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(textColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            if copyEnabled {
                Button(action: { UIPasteboard.general.string = value }) {
                    Text("SAO CHÉP")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(CyberYellow)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(CyberMediumBg)
                        .cornerRadius(8)
                }
                .fixedSize()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(CyberDarkBg.opacity(0.5))
        .cornerRadius(10)
    }
}

// MARK: - Admin Contact Row

struct AdminContactRow: View {
    let icon: String
    let platform: String
    let value: String
    let actionLabel: String
    let onAction: () -> Void

    var body: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(CyberMediumBg).frame(width: 28, height: 28)
                    Text(icon).font(.system(size: 14))
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(platform.uppercased())
                        .font(.system(size: 9, weight: .bold)).foregroundColor(CyberTextSecondary).kerning(0.5)
                    Text(value)
                        .font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            Spacer()
            Text(actionLabel)
                .font(.system(size: 9, weight: .black)).foregroundColor(CyberYellow)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(CyberYellow.opacity(0.15))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(CyberYellow.opacity(0.5), lineWidth: 1))
                .fixedSize()
        }
        .padding(.horizontal, 12).padding(.vertical, 10)
        .background(CyberDarkBg.opacity(0.4))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(CyberDarkBorder.opacity(0.5), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { onAction() }
    }
}

// MARK: - Advanced Tuner HUD (VIP only)

struct AdvancedTunerView: View {
    let dim: ViewDimensions
    let keyType: KeyType
    @Binding var dpiFactor: Float
    @Binding var stabilizationLevel: Float
    @Binding var responseMs: Int
    private var w: CGFloat { dim.w }
    private var h: CGFloat { dim.h }
    private var scale: CGFloat { dim.scale }
    private var hp: CGFloat { dim.w * 0.055 }

    var body: some View {
        let isVip = keyType == .vip
        VStack(alignment: .leading, spacing: h * 0.018) {
            Text("ADVANCED TUNER HUD")
                .font(.system(size: max(11, 12 * scale), weight: .bold)).foregroundColor(CyberIceYellow).kerning(1.2)

            VStack(spacing: h * 0.008) {
                HStack {
                    Text("TOUCH SENSITIVITY MULTIPLIER").font(.system(size: max(10, 11 * scale))).foregroundColor(CyberTextSecondary)
                    Spacer()
                    Text(String(format: "%.1fx", dpiFactor)).font(.system(size: max(11, 12 * scale), weight: .bold)).foregroundColor(CyberYellow)
                }
                Slider(value: $dpiFactor, in: 1.0...10.0, step: 0.1).tint(CyberYellow).disabled(!isVip)
            }

            VStack(spacing: h * 0.008) {
                HStack {
                    Text("RECOIL STABILIZATION FORCE").font(.system(size: max(10, 11 * scale))).foregroundColor(CyberTextSecondary)
                    Spacer()
                    Text("\(Int(stabilizationLevel))%").font(.system(size: max(11, 12 * scale), weight: .bold)).foregroundColor(CyberGreen)
                }
                Slider(value: $stabilizationLevel, in: 20...100, step: 1).tint(CyberGreen).disabled(!isVip)
            }

            HStack {
                Text("TOUCH RESPONSE ACCELERATION").font(.system(size: max(10, 11 * scale))).foregroundColor(CyberTextSecondary)
                Spacer()
                HStack(spacing: w * 0.015) {
                    ForEach([1, 2, 4, 8], id: \.self) { ms in
                        Button(action: { if isVip { responseMs = ms } }) {
                            Text("\(ms)ms")
                                .font(.system(size: max(9, 10 * scale), weight: .bold))
                                .foregroundColor(responseMs == ms ? .white : CyberTextSecondary)
                                .padding(.horizontal, w * 0.02).padding(.vertical, h * 0.005)
                                .background(responseMs == ms ? CyberYellow : CyberDarkBorder)
                                .cornerRadius(max(5, 6 * scale))
                        }
                        .disabled(!isVip)
                    }
                }
            }
        }
        .padding(hp)
        .background(isVip ? CyberSurface : CyberSurface.opacity(0.5))
        .cornerRadius(max(15, 20 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 20 * scale)).stroke(CyberDarkBorder, lineWidth: 1))
        .blur(radius: isVip ? 0 : 4)
        .overlay(
            !isVip ?
            AnyView(
                VStack(spacing: h * 0.008) {
                    Text("🔒 ADVANCED TUNER HUD")
                        .font(.system(size: max(12, 14 * scale), design: .monospaced).weight(.black)).foregroundColor(CyberAmber)
                    Text("Các tính năng chỉnh DPI, Recoil và Touch Acceleration chỉ được kích hoạt đối với thành viên VIP.")
                        .font(.system(size: max(10, 11 * scale))).foregroundColor(CyberTextSecondary).multilineTextAlignment(.center)
                    Text("Hãy đăng nhập bằng tài khoản VIP để mở khóa tối đa sức mạnh!")
                        .font(.system(size: max(9, 10 * scale))).foregroundColor(CyberYellow.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hexARGB: 0xE505020D))
                .cornerRadius(max(15, 20 * scale))
            )
            : AnyView(EmptyView())
        )
        .padding(.horizontal, hp)
    }
}

// MARK: - User Tab View

struct UserTabView: View {
    let dim: ViewDimensions
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String
    let onLogout: () -> Void
    private var w: CGFloat { dim.w }
    private var h: CGFloat { dim.h }
    private var scale: CGFloat { dim.scale }
    private var hp: CGFloat { dim.w * 0.055 }

    var body: some View {
        VStack(spacing: h * 0.03) {
            VStack(spacing: h * 0.018) {
                Image("Avatar")
                    .resizable().scaledToFill()
                    .frame(width: min(w * 0.18, 72), height: min(w * 0.18, 72))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(CyberYellow, lineWidth: max(1.5, 2 * scale)))

                Text(memberTitle)
                    .font(.system(size: max(14, 16 * scale), weight: .black))
                    .foregroundColor(memberColor)
                    .kerning(1)
                    .multilineTextAlignment(.center)

                VStack(spacing: h * 0.015) {
                    ProfileDetailRow(label: "Mã Kích Hoạt", value: licenseKey, copyEnabled: true)
                    ProfileDetailRow(label: "Loại Tài Khoản", value: accountTypeText)
                    ProfileDetailRow(label: "Thời Gian Hết Hạn",
                                     value: (expiresAt.isEmpty || expiresAt == "null") ? "Vĩnh viễn / Không giới hạn" : expiresAt)
                    ProfileDetailRow(label: "Mã Thiết Bị (HWID)", value: getHWID(), copyEnabled: true)
                    ProfileDetailRow(label: "Hệ Thống Phân Phối", value: "Plexus Cloud Auth v2.1")
                    ProfileDetailRow(label: "Trạng Thấu Xác Thực", value: "ĐA LIÊN KẾT THÀNH CÔNG ✅", textColor: CyberGreen)
                }
            }
            .padding(hp)
            .background(CyberCardBg)
            .cornerRadius(max(18, 24 * scale))
            .overlay(RoundedRectangle(cornerRadius: max(18, 24 * scale))
                .stroke(LinearGradient(colors: [CyberYellow, CyberDarkBorder], startPoint: .top, endPoint: .bottom), lineWidth: 1.5))
            .shadow(color: CyberYellow.opacity(0.3), radius: w * 0.04)

            VStack(alignment: .leading, spacing: h * 0.015) {
                HStack(spacing: w * 0.025) {
                    ZStack {
                        Circle().fill(CyberYellow.opacity(0.15)).frame(width: min(w * 0.08, 32), height: min(w * 0.08, 32))
                            .overlay(Circle().stroke(CyberYellow, lineWidth: 1))
                        Text("🛡️").font(.system(size: max(14, 16 * scale)))
                    }
                    VStack(alignment: .leading, spacing: h * 0.003) {
                        Text("QUẢN TRỊ VIÊN HỆ THỐNG")
                            .font(.system(size: max(10, 11 * scale), weight: .black)).foregroundColor(CyberYellow)
                            .kerning(1.2).shadow(color: CyberYellow.opacity(0.5), radius: w * 0.01)
                        Text("Hỗ trợ 24/7 & Kích hoạt bản quyền")
                            .font(.system(size: max(9, 10 * scale))).foregroundColor(CyberTextSecondary)
                    }
                }

                HStack(spacing: w * 0.03) {
                    ZStack {
                        Circle().fill(LinearGradient(colors: [CyberLockedColor, CyberGradientDark],
                                                     startPoint: .top, endPoint: .bottom)).frame(width: min(w * 0.11, 44), height: min(w * 0.11, 44))
                            .overlay(Circle().stroke(CyberAmber, lineWidth: 1.5))
                        Text("VA").font(.system(size: max(12, 14 * scale), design: .monospaced).weight(.black)).foregroundColor(CyberAmber)
                    }
                    VStack(alignment: .leading, spacing: h * 0.003) {
                        Text("Việt Anh").font(.system(size: max(13, 15 * scale), weight: .bold)).foregroundColor(.white)
                        Text("Plexus Developer & Distributor").font(.system(size: max(10, 11 * scale))).foregroundColor(CyberTextSecondary)
                    }
                    Spacer()
                }
                .padding(hp * 0.6)
                .background(CyberDarkBg.opacity(0.6))
                .cornerRadius(max(10, 12 * scale))

                AdminContactRow(icon: "💬", platform: "Zalo Admin", value: "0377045762", actionLabel: "MỞ & COPY") {
                    UIPasteboard.general.string = "0377045762"
                    if let url = URL(string: "tel:0377045762") { UIApplication.shared.open(url, options: [:]) }
                }
                AdminContactRow(icon: "✈️", platform: "Telegram Admin", value: "@trnmnhkh", actionLabel: "LIÊN HỆ") {
                    UIPasteboard.general.string = "@trnmnhkh"
                    if let url = URL(string: "https://t.me/trnmnhkh") { UIApplication.shared.open(url, options: [:]) }
                }
            }
            .padding(hp)
            .background(CyberCardBg)
            .cornerRadius(max(15, 20 * scale))
            .overlay(RoundedRectangle(cornerRadius: max(15, 20 * scale)).stroke(CyberYellow.opacity(0.5), lineWidth: 1.2))
            .shadow(color: CyberYellow.opacity(0.2), radius: w * 0.03)

            Button(action: {
                onLogout()
            }) {
                Text("ĐĂNG XUẤT TÀI KHOẢN / ĐỔI KEY 🚪")
                    .font(.system(size: max(10, 11 * scale), design: .monospaced).weight(.bold))
                    .foregroundColor(Color(hexARGB: 0xFFFF5252))
                    .kerning(0.8)
                    .padding(.horizontal, w * 0.04).padding(.vertical, h * 0.012)
                    .background(Color.red.opacity(0.07))
                    .cornerRadius(max(10, 12 * scale))
                    .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(Color.red.opacity(0.5), lineWidth: 1))
            }
        }
        .padding(.horizontal, hp)
    }

    private var memberTitle: String {
        switch keyType {
        case .vip: return "THÀNH VIÊN VIP PREMIUM"
        case .pro: return "THÀNH VIÊN PRO SPECIAL"
        case .basic: return "THÀNH VIÊN BASIC FREE"
        }
    }

    private var memberColor: Color {
        switch keyType {
        case .vip: return CyberAmber
        case .pro: return CyberYellow
        case .basic: return CyberIceYellow
        }
    }

    private var accountTypeText: String {
        switch keyType {
        case .vip: return "VIP SUPREME 👑"
        case .pro: return "PRO EDITION ⚡"
        case .basic: return "FREE BASIC"
        }
    }
}
