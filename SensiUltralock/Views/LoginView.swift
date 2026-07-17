import SwiftUI

struct LoginView: View {
    let onLoginSuccess: (Bool, String, String, KeyType) -> Void
    var notificationMessage: String = ""

    @State private var keyInput = ""
    @State private var isConnecting = false
    @State private var errorMessage = ""
    @State private var showTrialAlert = false
    @FocusState private var isKeyFieldFocused: Bool

    var body: some View {
        ZStack {
            CyberGridBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 26) {
                    headerBrand
                    notificationBanner
                    activationCard
                    contactRow
                    communityCard
                }
                .padding(.horizontal, 22)
                .padding(.top, 16)
                .padding(.bottom, 30)
            }
            .scrollIndicators(.hidden)
        }
        .alert("Mã thử nghiệm", isPresented: $showTrialAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Đã điền mã PLEXUS-VIP-TEST. Nhấn XÁC THỰC NGAY để tiếp tục.")
        }
    }

    // MARK: - Brand Header

    private var headerBrand: some View {
        VStack(spacing: 14) {
            ShieldLogo(size: 100)

            VStack(spacing: 6) {
                Text("Sensi Ultralock")
                    .font(.system(size: 28, weight: .heavy, design: .serif).italic())
                    .foregroundStyle(CyberTheme.textPrimary)
                    .tracking(2)
                    .cyberGlow(CyberTheme.cyberCyan, radius: 10, opacity: 0.6)
                Text("HỆ THỐNG TỐI ƯU CẤU HÌNH FREE FIRE")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundStyle(CyberTheme.textSecondary)
                    .tracking(1.5)
            }
        }
        .padding(.top, 20)
    }

    // MARK: - Notification

    @ViewBuilder
    private var notificationBanner: some View {
        if !notificationMessage.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(notificationMessage)
                    .font(.footnote.weight(.semibold))
            }
            .foregroundStyle(CyberTheme.cyberGold)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(hexARGB: 0x22FFD700))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(hexARGB: 0x44FFD700), lineWidth: 1))
        }
    }

    // MARK: - Activation Card

    private var activationCard: some View {
        CyberCard {
            VStack(spacing: 18) {
                Text("KÍCH HOẠT HỆ THỐNG PLEXUS")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .foregroundStyle(CyberTheme.cyberCyan)
                    .tracking(2)

                VStack(alignment: .leading, spacing: 6) {
                    Text("LICENSE KEY")
                        .font(CyberTheme.monoFontSmall)
                        .foregroundStyle(CyberTheme.textSecondary)
                        .tracking(2)
                    TextField("PLEXUS-XXXX-XXXX", text: $keyInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(CyberTheme.monoFont.weight(.bold))
                        .foregroundStyle(CyberTheme.textPrimary)
                        .padding(.horizontal, 16).padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(hexARGB: 0x0F0422))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(CyberTheme.cyberCyan.opacity(0.6), lineWidth: 1.4)
                        )
                        .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.35)
                        .focused($isKeyFieldFocused)
                }

                if !errorMessage.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text(errorMessage)
                            .font(.footnote)
                    }
                    .foregroundStyle(CyberTheme.dangerRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Haptics.medium()
                    loginAction()
                } label: {
                    HStack {
                        if isConnecting {
                            ProgressView().tint(CyberTheme.cyberBgTop)
                        } else {
                            Image(systemName: "shield.lefthalf.filled")
                        }
                        Text(isConnecting ? "ĐANG XÁC THỰC…" : "XÁC THỰC NGAY")
                            .font(.system(.headline, design: .rounded).weight(.heavy))
                            .tracking(1.5)
                    }
                    .foregroundStyle(CyberTheme.cyberBgTop)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(CyberTheme.cyanGlowGradient)
                    )
                    .cyberGlow(CyberTheme.cyberCyan, radius: 14, opacity: 0.7)
                }
                .buttonStyle(.plain)
                .disabled(isConnecting)

                Button {
                    Haptics.light()
                    keyInput = "PLEXUS-VIP-TEST"
                    showTrialAlert = true
                } label: {
                    Text("Nhấp để điền mã Key thử nghiệm miễn phí")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(CyberTheme.cyberGold)
                        .underline(true, color: CyberTheme.cyberGold.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Contact

    private var contactRow: some View {
        HStack(spacing: 14) {
            contactPill(icon: "paperplane.fill", label: "Telegram", tint: CyberTheme.cyberCyan) {
                copyAndOpen(text: "@SensiUltralock_VIP", toast: "Đã sao chép Telegram!", openURL: "https://t.me/SensiUltralock_VIP")
            }
            contactPill(icon: "bubble.left.fill", label: "Zalo", tint: CyberTheme.cyberGold) {
                copyAndOpen(text: "098.334.88xx", toast: "Đã sao chép SĐT Zalo!", openURL: "tel:09833488xx")
            }
        }
    }

    private func contactPill(icon: String, label: String, tint: Color, action: @escaping () -> Void) -> some View {
        Button { Haptics.medium(); action() } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                Text(label)
                    .font(.system(.subheadline, design: .rounded).weight(.semibold))
            }
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(CyberTheme.darkBorder))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(tint.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Community

    private var communityCard: some View {
        Button {
            Haptics.medium()
            copyAndOpen(text: "Group Zalo SensiUltralock", toast: "Đã sao chép link cộng đồng!", openURL: "https://zalo.me/g/sensiultralock")
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(CyberTheme.cyberPurple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cộng Đồng Zalo")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .foregroundStyle(CyberTheme.textPrimary)
                    Text("Tham gia group chia sẻ kinh nghiệm")
                        .font(.caption)
                        .foregroundStyle(CyberTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(CyberTheme.textSecondary)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(CyberTheme.cyberPurple.opacity(0.15)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(CyberTheme.cyberPurple.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Login Action

    private func loginAction() {
        let key = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            errorMessage = "Vui lòng nhập License Key!"
            return
        }
        isConnecting = true
        errorMessage = ""
        Task {
            let result = await verifyLicenseKey(key: key)
            await MainActor.run {
                isConnecting = false
                if let r = result, r.success, r.status == "valid" {
                    let computedType = computeKeyType(from: r.type)
                    let isVip = computedType == .vip
                    onLoginSuccess(isVip, key, r.expiresAt, computedType)
                } else {
                    errorMessage = result?.message ?? "Mã kích hoạt không hợp lệ hoặc đã hết hạn!"
                }
            }
        }
    }

    private func copyAndOpen(text: String, toast: String, openURL: String) {
        UIPasteboard.general.string = text
        ToastManager.shared.show(toast, type: .success)
        if let url = URL(string: openURL) { UIApplication.shared.open(url) }
    }
}
