import SwiftUI

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
        ZStack {
            Circle()
                .stroke(CyberDarkBorder, lineWidth: 6)
            Circle()
                .trim(from: 0, to: CGFloat(min(animatedProgress, 1.0)))
                .stroke(CyberYellow, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animatedProgress)

            VStack(spacing: 0) {
                Text("\(Int(animatedProgress * 100))%")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                    .shadow(color: CyberYellow, radius: 4)
                Text("BOOSTED")
                    .font(.system(size: 7, weight: .bold))
                    .foregroundColor(CyberYellow)
                    .kerning(0.5)
            }
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
                            .frame(width: 12, height: 12)
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
                }
            }
            Spacer()
            Text(actionLabel)
                .font(.system(size: 9, weight: .black)).foregroundColor(CyberYellow)
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(CyberYellow.opacity(0.15))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(CyberYellow.opacity(0.5), lineWidth: 1))
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
    let keyType: KeyType
    @Binding var dpiFactor: Float
    @Binding var stabilizationLevel: Float
    @Binding var responseMs: Int

    var body: some View {
        let isVip = keyType == .vip
        VStack(alignment: .leading, spacing: 14) {
            Text("ADVANCED TUNER HUD")
                .font(.system(size: 12, weight: .bold)).foregroundColor(CyberIceYellow).kerning(1.2)

            // DPI Slider
            VStack(spacing: 6) {
                HStack {
                    Text("TOUCH SENSITIVITY MULTIPLIER").font(.system(size: 11)).foregroundColor(CyberTextSecondary)
                    Spacer()
                    Text(String(format: "%.1fx", dpiFactor)).font(.system(size: 12, weight: .bold)).foregroundColor(CyberYellow)
                }
                Slider(value: $dpiFactor, in: 1.0...10.0, step: 0.1).tint(CyberYellow).disabled(!isVip)
            }

            // Recoil
            VStack(spacing: 6) {
                HStack {
                    Text("RECOIL STABILIZATION FORCE").font(.system(size: 11)).foregroundColor(CyberTextSecondary)
                    Spacer()
                    Text("\(Int(stabilizationLevel))%").font(.system(size: 12, weight: .bold)).foregroundColor(CyberGreen)
                }
                Slider(value: $stabilizationLevel, in: 20...100, step: 1).tint(CyberGreen).disabled(!isVip)
            }

            // Touch Response
            HStack {
                Text("TOUCH RESPONSE ACCELERATION").font(.system(size: 11)).foregroundColor(CyberTextSecondary)
                Spacer()
                HStack(spacing: 6) {
                    ForEach([1, 2, 4, 8], id: \.self) { ms in
                        Button(action: { if isVip { responseMs = ms } }) {
                            Text("\(ms)ms")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(responseMs == ms ? .white : CyberTextSecondary)
                                .padding(.horizontal, 8).padding(.vertical, 4)
                                .background(responseMs == ms ? CyberYellow : CyberDarkBorder)
                                .cornerRadius(6)
                        }
                        .disabled(!isVip)
                    }
                }
            }
        }
        .padding(16)
        .background(isVip ? CyberSurface : CyberSurface.opacity(0.5))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(CyberDarkBorder, lineWidth: 1))
        .blur(radius: isVip ? 0 : 4)
        .overlay(
            !isVip ?
            AnyView(
                VStack(spacing: 6) {
                    Text("🔒 ADVANCED TUNER HUD")
                        .font(.system(size: 14, design: .monospaced).weight(.black)).foregroundColor(CyberAmber)
                    Text("Các tính năng chỉnh DPI, Recoil và Touch Acceleration chỉ được kích hoạt đối với thành viên VIP.")
                        .font(.system(size: 11)).foregroundColor(CyberTextSecondary).multilineTextAlignment(.center)
                    Text("Hãy đăng nhập bằng tài khoản VIP để mở khóa tối đa sức mạnh!")
                        .font(.system(size: 10)).foregroundColor(CyberYellow.opacity(0.8))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hexARGB: 0xE505020D))
                .cornerRadius(20)
            )
            : AnyView(EmptyView())
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - User Tab View

struct UserTabView: View {
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String
    let onLogout: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Profile Card
            VStack(spacing: 14) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable().scaledToFit()
                    .frame(width: 72, height: 72)
                    .clipShape(Circle())
                    .background(Circle().fill(CyberMediumBg))
                    .overlay(Circle().stroke(CyberYellow, lineWidth: 2))
                    .foregroundColor(CyberYellow.opacity(0.8))

                Text(memberTitle)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(memberColor)
                    .kerning(1)

                VStack(spacing: 12) {
                    ProfileDetailRow(label: "Mã Kích Hoạt", value: licenseKey, copyEnabled: true)
                    ProfileDetailRow(label: "Loại Tài Khoản", value: accountTypeText)
                    ProfileDetailRow(label: "Thời Gian Hết Hạn",
                                     value: (expiresAt.isEmpty || expiresAt == "null") ? "Vĩnh viễn / Không giới hạn" : expiresAt)
                    ProfileDetailRow(label: "Mã Thiết Bị (HWID)", value: getHWID(), copyEnabled: true)
                    ProfileDetailRow(label: "Hệ Thống Phân Phối", value: "Plexus Cloud Auth v2.1")
                    ProfileDetailRow(label: "Trạng Thấu Xác Thực", value: "ĐA LIÊN KẾT THÀNH CÔNG ✅", textColor: CyberGreen)
                }
            }
            .padding(20)
            .background(CyberCardBg)
            .cornerRadius(24)
            .overlay(RoundedRectangle(cornerRadius: 24)
                .stroke(LinearGradient(colors: [CyberYellow, CyberDarkBorder], startPoint: .top, endPoint: .bottom), lineWidth: 1.5))
            .shadow(color: CyberYellow.opacity(0.3), radius: 16)

            // Admin Panel
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle().fill(CyberYellow.opacity(0.15)).frame(width: 32, height: 32)
                            .overlay(Circle().stroke(CyberYellow, lineWidth: 1))
                        Text("🛡️").font(.system(size: 16))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("QUẢN TRỊ VIÊN HỆ THỐNG")
                            .font(.system(size: 11, weight: .black)).foregroundColor(CyberYellow)
                            .shadow(color: CyberYellow.opacity(0.5), radius: 4).kerning(1.2)
                        Text("Hỗ trợ 24/7 & Kích hoạt bản quyền")
                            .font(.system(size: 10)).foregroundColor(CyberTextSecondary)
                    }
                }

                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(LinearGradient(colors: [CyberLockedColor, CyberGradientDark],
                                                     startPoint: .top, endPoint: .bottom)).frame(width: 44, height: 44)
                            .overlay(Circle().stroke(CyberAmber, lineWidth: 1.5))
                        Text("VA").font(.system(size: 14, design: .monospaced).weight(.black)).foregroundColor(CyberAmber)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Việt Anh").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        Text("Plexus Developer & Distributor").font(.system(size: 11)).foregroundColor(CyberTextSecondary)
                    }
                    Spacer()
                }
                .padding(12)
                .background(CyberDarkBg.opacity(0.6))
                .cornerRadius(12)

                AdminContactRow(icon: "💬", platform: "Zalo Admin", value: "0377045762", actionLabel: "MỞ & COPY") {
                    UIPasteboard.general.string = "0377045762"
                    if let url = URL(string: "tel:0377045762") { UIApplication.shared.open(url, options: [:]) }
                }
                AdminContactRow(icon: "✈️", platform: "Telegram Admin", value: "@trnmnhkh", actionLabel: "LIÊN HỆ") {
                    UIPasteboard.general.string = "@trnmnhkh"
                    if let url = URL(string: "https://t.me/trnmnhkh") { UIApplication.shared.open(url, options: [:]) }
                }
            }
            .padding(16)
            .background(CyberCardBg)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(CyberYellow.opacity(0.5), lineWidth: 1.2))
            .shadow(color: CyberYellow.opacity(0.2), radius: 12)

            // Logout
            Button(action: {
                KeychainManager.delete(key: "saved_key")
                onLogout()
            }) {
                Text("ĐĂNG XUẤT TÀI KHOẢN / ĐỔI KEY 🚪")
                    .font(.system(size: 11, design: .monospaced).weight(.bold))
                    .foregroundColor(Color(hexARGB: 0xFFFF5252))
                    .kerning(0.8)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color.red.opacity(0.07))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.5), lineWidth: 1))
            }
        }
        .padding(.horizontal, 20)
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
