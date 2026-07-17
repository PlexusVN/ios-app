import SwiftUI
import UIKit

// MARK: - Custom Neon Toggle

struct CustomToggleView: View {
    let checked: Bool
    let onCheckedChange: (Bool) -> Void

    @State private var thumbOffset: CGFloat = 0
    private let trackWidth: CGFloat = 44
    private let trackHeight: CGFloat = 24
    private let thumbSize: CGFloat = 18
    private let paddingTrack: CGFloat = 3

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
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                onCheckedChange(!checked)
            }
        }
        .onAppear { updateThumb() }
        .onChange(of: checked) { _ in updateThumb() }
    }

    private func updateThumb() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            thumbOffset = checked ? trackWidth - thumbSize - paddingTrack * 2 : 0
        }
    }
}

// MARK: - Circular Gauge

struct CircularGaugeView: View {
    let ratio: Float
    @State private var animatedProgress: Float = 0

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineW = max(4, size * 0.09)
            ZStack {
                Circle().stroke(CyberDarkBorder, lineWidth: lineW)
                Circle()
                    .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                    .stroke(CyberYellow, style: StrokeStyle(lineWidth: lineW, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animatedProgress)

                Circle()
                    .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                    .stroke(CyberYellow.opacity(0.3), style: StrokeStyle(lineWidth: lineW * 1.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .blur(radius: 4)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animatedProgress)

                VStack(spacing: 0) {
                    Text("\(Int(animatedProgress * 100))%")
                        .font(.system(size: max(10, size * 0.2), weight: .black))
                        .foregroundColor(.white)
                        .neonGlow(color: CyberYellow, radius: 3, intensity: 0.5)
                    Text("BOOSTED")
                        .font(.system(size: max(5, size * 0.09), weight: .bold))
                        .foregroundColor(CyberYellow)
                        .customTracking(0.5)
                }
            }
            .frame(width: size, height: size)
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

    @State private var borderColor: Color = CyberDarkBorder
    @State private var cardScale: CGFloat = 1.0

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(feature.name)
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(isLocked ? CyberYellow : .white)
                        .customTracking(0.3)

                    if feature.isVipOnly || isLocked {
                        Text(isLocked ? "LOCKED" : "VIP")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(isLocked ? .white : .black)
                            .padding(.horizontal, 4).padding(.vertical, 1)
                            .background(isLocked ? CyberLockedColor : CyberAmber)
                            .cornerRadius(4)
                    }
                }

                HStack(spacing: 5) {
                    Image(systemName: isLocked ? "lock.fill" : "checkmark")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(isLocked ? CyberLockedColor : CyberGreen)
                        .frame(width: 10)
                    Text(feature.description)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundColor(isLocked ? CyberTextSecondary.opacity(0.6) : CyberTextSecondary)
                }
            }

            Spacer()

            if isLocked {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(CyberLockedColor.opacity(0.25))
                        .frame(width: 44, height: 24)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                            .stroke(CyberLockedColor.opacity(0.4), lineWidth: 1))
                    Text("🔒").font(.system(size: 9))
                }
            } else {
                CustomToggleView(checked: isChecked, onCheckedChange: onToggle)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
        .background(
            ZStack {
                CyberDarkBg
                if isChecked && !isLocked {
                    CyberYellow.opacity(0.05)
                }
            }
        )
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor, lineWidth: 1))
        .scaleEffect(cardScale)
        .onAppear { updateBorder() }
        .onChange(of: isChecked) { _ in
            updateBorder()
            withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                cardScale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    cardScale = 1.0
                }
            }
        }
        .onChange(of: isLocked) { _ in updateBorder() }
    }

    private func updateBorder() {
        withAnimation(.easeInOut(duration: 0.25)) {
            if isLocked { borderColor = CyberLockedColor.opacity(0.4) }
            else if isChecked { borderColor = CyberYellow }
            else { borderColor = CyberDarkBorder }
        }
    }
}

// MARK: - Profile Detail Row

struct ProfileDetailRow: View {
    let label: String
    let value: String
    var copyEnabled: Bool = false
    var textColor: Color = .white
    var copyToastMessage: String? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(CyberTextSecondary)
                    .customTracking(0.6)
                Text(value)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer()
            if copyEnabled {
                Button(action: {
                    UIPasteboard.general.string = value
                    if let msg = copyToastMessage {
                        ToastManager.shared.show("Đã sao chép \(msg)!", type: .success)
                    }
                }) {
                    Text("SAO CHÉP")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(CyberYellow)
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(CyberMediumBg)
                        .cornerRadius(7)
                }
                .fixedSize()
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(CyberDarkBg.opacity(0.4))
        .cornerRadius(9)
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
            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(CyberMediumBg).frame(width: 26, height: 26)
                    Text(icon).font(.system(size: 12))
                }
                VStack(alignment: .leading, spacing: 0) {
                    Text(platform.uppercased())
                        .font(.system(size: 8, weight: .bold)).foregroundColor(CyberTextSecondary).customTracking(0.4)
                    Text(value)
                        .font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            Spacer()
            Text(actionLabel)
                .font(.system(size: 8, weight: .black)).foregroundColor(CyberYellow)
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(CyberYellow.opacity(0.12))
                .cornerRadius(7)
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(CyberYellow.opacity(0.4), lineWidth: 1))
                .fixedSize()
        }
        .padding(.horizontal, 11).padding(.vertical, 9)
        .background(CyberDarkBg.opacity(0.35))
        .cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(CyberDarkBorder.opacity(0.4), lineWidth: 1))
        .contentShape(Rectangle())
        .onTapGesture { onAction() }
    }
}

// MARK: - Advanced Tuner HUD

struct AdvancedTunerView: View {
    let dim: ViewDimensions
    let keyType: KeyType
    @Binding var dpiFactor: Float
    @Binding var stabilizationLevel: Float
    @Binding var responseMs: Int

    private var w: CGFloat { dim.w }
    private var h: CGFloat { dim.h }
    private var scale: CGFloat { dim.scale }
    private var hp: CGFloat { dim.w * 0.045 }
    private var isVip: Bool { keyType == .vip }

    var body: some View {
        VStack(alignment: .leading, spacing: h * 0.014) {
            Text("ADVANCED TUNER HUD")
                .font(.system(size: max(11, 12 * scale), weight: .bold))
                .foregroundColor(CyberIceYellow)
                .customTracking(1)

            VStack(spacing: h * 0.006) {
                HStack {
                    Text("TOUCH SENSITIVITY")
                        .font(.system(size: max(9, 10 * scale)))
                        .foregroundColor(CyberTextSecondary)
                    Spacer()
                    Text(String(format: "%.1fx", dpiFactor))
                        .font(.system(size: max(10, 11 * scale), weight: .bold))
                        .foregroundColor(CyberYellow)
                }
                Slider(value: $dpiFactor, in: 1.0...10.0, step: 0.1)
                    .tint(CyberYellow)
                    .disabled(!isVip)
            }

            VStack(spacing: h * 0.006) {
                HStack {
                    Text("RECOIL STABILIZATION")
                        .font(.system(size: max(9, 10 * scale)))
                        .foregroundColor(CyberTextSecondary)
                    Spacer()
                    Text("\(Int(stabilizationLevel))%")
                        .font(.system(size: max(10, 11 * scale), weight: .bold))
                        .foregroundColor(CyberGreen)
                }
                Slider(value: $stabilizationLevel, in: 20...100, step: 1)
                    .tint(CyberGreen)
                    .disabled(!isVip)
            }

            HStack {
                Text("TOUCH RESPONSE")
                    .font(.system(size: max(9, 10 * scale)))
                    .foregroundColor(CyberTextSecondary)
                Spacer()
                HStack(spacing: w * 0.012) {
                    ForEach([1, 2, 4, 8], id: \.self) { ms in
                        Button(action: { if isVip { responseMs = ms } }) {
                            Text("\(ms)ms")
                                .font(.system(size: max(8, 9 * scale), weight: .bold))
                                .foregroundColor(responseMs == ms ? .white : CyberTextSecondary)
                                .padding(.horizontal, w * 0.018)
                                .padding(.vertical, h * 0.004)
                                .background(responseMs == ms ? CyberYellow : CyberDarkBorder)
                                .cornerRadius(max(5, 6 * scale))
                        }
                        .disabled(!isVip)
                    }
                }
            }
        }
        .padding(hp)
        .padding(.vertical, h * 0.012)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale))
            .stroke(CyberDarkBorder, lineWidth: 1))
        .padding(.horizontal, hp)
        .overlay(
            Group {
                if !isVip {
                    Color(hexARGB: 0xCC05020E)
                        .cornerRadius(max(15, 18 * scale))
                        .overlay(
                            VStack(spacing: h * 0.008) {
                                Text("🔒 ADVANCED TUNER HUD")
                                    .font(.system(size: max(11, 12 * scale), design: .monospaced).weight(.black))
                                    .foregroundColor(CyberAmber)
                                Text("Chỉ dành cho thành viên VIP")
                                    .font(.system(size: max(9, 10 * scale)))
                                    .foregroundColor(CyberTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            ToastManager.shared.show("Chức năng nâng cao chỉ dành cho tài khoản VIP!", type: .warning)
                        }
                }
            }
        )
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
    private var hp: CGFloat { dim.w * 0.045 }

    var body: some View {
        VStack(spacing: h * 0.022) {
            profileCard
            adminCard
            logoutButton
        }
        .padding(.horizontal, hp)
    }

    private var profileCard: some View {
        VStack(spacing: h * 0.014) {
            Image("Avatar")
                .resizable().scaledToFill()
                .frame(width: min(w * 0.16, 64), height: min(w * 0.16, 64))
                .clipShape(Circle())
                .overlay(Circle().stroke(CyberYellow, lineWidth: max(1.5, 2 * scale)))

            Text(memberTitle)
                .font(.system(size: max(13, 15 * scale), weight: .black))
                .foregroundColor(memberColor)
                .customTracking(1)
                .multilineTextAlignment(.center)

            VStack(spacing: h * 0.012) {
                ProfileDetailRow(label: "Mã Kích Hoạt", value: licenseKey, copyEnabled: true, copyToastMessage: "Mã Kích Hoạt")
                ProfileDetailRow(label: "Loại Tài Khoản", value: accountTypeText)
                ProfileDetailRow(label: "Thời Gian Hết Hạn",
                                 value: (expiresAt.isEmpty || expiresAt == "null") ? "Vĩnh viễn" : expiresAt)
                ProfileDetailRow(label: "Mã Thiết Bị (HWID)", value: getHWID(), copyEnabled: true, copyToastMessage: "Mã Thiết Bị (HWID)")
                ProfileDetailRow(label: "Hệ Thống", value: "Plexus Cloud Auth v2.1")
                ProfileDetailRow(label: "Trạng Thái", value: "ĐÃ XÁC THỰC ✅", textColor: CyberGreen)
            }
        }
        .padding(hp)
        .background(CyberCardBg)
        .cornerRadius(max(18, 22 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(18, 22 * scale))
            .stroke(LinearGradient(colors: [CyberYellow, CyberDarkBorder], startPoint: .top, endPoint: .bottom), lineWidth: 1.5))
        .shadow(color: CyberYellow.opacity(0.2), radius: w * 0.03)
    }

    private var adminCard: some View {
        VStack(alignment: .leading, spacing: h * 0.012) {
            HStack(spacing: w * 0.02) {
                ZStack {
                    Circle().fill(CyberYellow.opacity(0.12)).frame(width: min(w * 0.07, 28), height: min(w * 0.07, 28))
                        .overlay(Circle().stroke(CyberYellow, lineWidth: 0.5))
                    Text("🛡️").font(.system(size: max(12, 14 * scale)))
                }
                VStack(alignment: .leading, spacing: h * 0.002) {
                    Text("QUẢN TRỊ VIÊN HỆ THỐNG")
                        .font(.system(size: max(9, 10 * scale), weight: .black))
                        .foregroundColor(CyberYellow)
                        .customTracking(1)
                    Text("Hỗ trợ 24/7 & Kích hoạt bản quyền")
                        .font(.system(size: max(8, 9 * scale)))
                        .foregroundColor(CyberTextSecondary)
                }
            }

            HStack(spacing: w * 0.025) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [CyberLockedColor, CyberGradientDark],
                                                 startPoint: .top, endPoint: .bottom))
                        .frame(width: min(w * 0.1, 40), height: min(w * 0.1, 40))
                        .overlay(Circle().stroke(CyberAmber, lineWidth: 1))
                    Text("VA").font(.system(size: max(11, 12 * scale), design: .monospaced).weight(.black)).foregroundColor(CyberAmber)
                }
                VStack(alignment: .leading, spacing: h * 0.002) {
                    Text("Việt Anh").font(.system(size: max(12, 13 * scale), weight: .bold)).foregroundColor(.white)
                    Text("Plexus Developer & Distributor").font(.system(size: max(9, 10 * scale))).foregroundColor(CyberTextSecondary)
                }
                Spacer()
            }
            .padding(hp * 0.5)
            .background(CyberDarkBg.opacity(0.5))
            .cornerRadius(max(10, 11 * scale))

            AdminContactRow(icon: "💬", platform: "Zalo Admin", value: "0377045762", actionLabel: "MỞ & COPY") {
                UIPasteboard.general.string = "0377045762"
                ToastManager.shared.show("Đã sao chép SĐT Zalo Việt Anh!", type: .success)
                if let url = URL(string: "tel:0377045762") { UIApplication.shared.open(url, options: [:]) }
            }
            AdminContactRow(icon: "✈️", platform: "Telegram Admin", value: "@trnmnhkh", actionLabel: "LIÊN HỆ") {
                UIPasteboard.general.string = "@trnmnhkh"
                ToastManager.shared.show("Đã sao chép Telegram Việt Anh!", type: .success)
                if let url = URL(string: "https://t.me/trnmnhkh") { UIApplication.shared.open(url, options: [:]) }
            }
        }
        .padding(hp)
        .background(CyberCardBg)
        .cornerRadius(max(15, 18 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(15, 18 * scale)).stroke(CyberYellow.opacity(0.4), lineWidth: 1.2))
        .shadow(color: CyberYellow.opacity(0.15), radius: w * 0.025)
    }

    private var logoutButton: some View {
        Button(action: onLogout) {
            Text("ĐĂNG XUẤT / ĐỔI KEY")
                .font(.system(size: max(10, 11 * scale), design: .monospaced).weight(.bold))
                .foregroundColor(Color(hexARGB: 0xFFFF5252))
                .customTracking(0.8)
                .padding(.horizontal, w * 0.04)
                .padding(.vertical, h * 0.012)
                .background(Color.red.opacity(0.06))
                .cornerRadius(max(10, 11 * scale))
                .overlay(RoundedRectangle(cornerRadius: max(10, 11 * scale)).stroke(Color.red.opacity(0.4), lineWidth: 1))
        }
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
        case .vip: return "VIP SUPREME"
        case .pro: return "PRO EDITION"
        case .basic: return "FREE BASIC"
        }
    }
}

// MARK: - Toast Notification System

final class ToastManager: ObservableObject {
    static let shared = ToastManager()

    @Published var message: String = ""
    @Published var isVisible: Bool = false
    @Published var toastType: ToastType = .info

    private var workItem: DispatchWorkItem?

    enum ToastType {
        case success, error, info, warning
        var color: Color {
            switch self {
            case .success: return CyberGreen
            case .error: return .red
            case .info: return CyberYellow
            case .warning: return CyberAmber
            }
        }
        var icon: String {
            switch self {
            case .success: return "✅"
            case .error: return "❌"
            case .info: return "⚡"
            case .warning: return "⚠️"
            }
        }
    }

    func show(_ message: String, type: ToastType = .info, duration: Double = 2.0) {
        workItem?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            self.message = message
            self.toastType = type
            self.isVisible = true
        }
        let item = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 0.25)) {
                self?.isVisible = false
            }
        }
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
    }

    func hide() {
        workItem?.cancel()
        withAnimation(.easeOut(duration: 0.25)) {
            isVisible = false
        }
    }
}

struct ToastModifier: ViewModifier {
    @ObservedObject var manager: ToastManager
    let bottomPadding: CGFloat

    func body(content: Content) -> some View {
        content.overlay(alignment: .bottom) {
            if manager.isVisible {
                HStack(spacing: 8) {
                    Text(manager.toastType.icon)
                        .font(.system(size: 14))
                    Text(manager.message)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        CyberDarkBg.opacity(0.95)
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(manager.toastType.color.opacity(0.5), lineWidth: 1)
                    }
                )
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(manager.toastType.color.opacity(0.5), lineWidth: 1))
                .padding(.horizontal, 20)
                .padding(.bottom, bottomPadding + 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onTapGesture { manager.hide() }
            }
        }
    }
}

// MARK: - iOS 15 tracking compatibility

extension View {
    @ViewBuilder
    func customTracking(_ amount: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            tracking(amount)
        } else {
            self
        }
    }
}
