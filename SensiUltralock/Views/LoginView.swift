import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showTrialAlert = false

    var body: some View {
        ZStack {
            CyberGridBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    headerBrand
                    notificationBanner
                    activationCard
                    contactRow
                    communityCard
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 20)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Mã thử nghiệm", isPresented: $showTrialAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Đã điền mã PLEXUS-VIP-TEST. Nhấn XÁC THỰC NGAY để tiếp tục.")
        }
    }

    // MARK: - Brand Header

    private var headerBrand: some View {
        VStack(spacing: 8) {
            ShieldLogo(size: 60)

            VStack(spacing: 4) {
                Text("Sensi Ultralock")
                    .font(.system(size: 22, weight: .heavy, design: .serif).italic())
                    .foregroundStyle(CyberTheme.textPrimary)
                    .tracking(1.5)
                    .cyberGlow(CyberTheme.cyberCyan, radius: 8, opacity: 0.5)
                Text("HỆ THỐNG TỐI ƯU CẤU HÌNH FREE FIRE")
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundStyle(CyberTheme.textSecondary)
                    .tracking(1)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Notification

    @ViewBuilder
    private var notificationBanner: some View {
        if !viewModel.serverConnected {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text("Máy chủ Plexus đang ngoại tuyến. Một số tính năng có thể không hoạt động.")
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
            VStack(spacing: 12) {
                Text("KÍCH HOẠT HỆ THỐNG PLEXUS")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundStyle(CyberTheme.cyberCyan)
                    .tracking(1.5)

                VStack(alignment: .leading, spacing: 4) {
                    Text("LICENSE KEY")
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(CyberTheme.textSecondary)
                        .tracking(1.5)
                    TextField("PLEXUS-XXXX-XXXX", text: $viewModel.keyInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(CyberTheme.monoFont.weight(.bold))
                        .foregroundStyle(CyberTheme.textPrimary)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hexARGB: 0x0F0422))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(CyberTheme.cyberCyan.opacity(0.6), lineWidth: 1.2)
                        )
                        .cyberGlow(CyberTheme.cyberCyan, radius: 4, opacity: 0.3)
                }

                if let err = viewModel.authError {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 10))
                        Text(err)
                            .font(.caption2)
                    }
                    .foregroundStyle(CyberTheme.dangerRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Haptics.medium()
                    Task { await viewModel.verifyKey() }
                } label: {
                    HStack {
                        if viewModel.isVerifying {
                            ProgressView().tint(CyberTheme.cyberBgTop)
                        } else {
                            Image(systemName: "shield.lefthalf.filled")
                        }
                        Text(viewModel.isVerifying ? "ĐANG XÁC THỰC…" : "XÁC THỰC NGAY")
                            .font(.system(.subheadline, design: .rounded).weight(.heavy))
                            .tracking(1)
                    }
                    .foregroundStyle(CyberTheme.cyberBgTop)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(CyberTheme.cyanGlowGradient)
                    )
                    .cyberGlow(CyberTheme.cyberCyan, radius: 10, opacity: 0.6)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isVerifying)

                Button {
                    Haptics.light()
                    viewModel.keyInput = "PLEXUS-VIP-TEST"
                    showTrialAlert = true
                } label: {
                    Text("Nhấp để điền mã Key thử nghiệm miễn phí")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(CyberTheme.cyberGold)
                        .underline(true, color: CyberTheme.cyberGold.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Contact

    private var contactRow: some View {
        HStack(spacing: 10) {
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
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(CyberTheme.darkBorder))
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

    // MARK: - Helpers

    private func copyAndOpen(text: String, toast: String, openURL: String) {
        UIPasteboard.general.string = text
        viewModel.showToast(toast)
        if let url = URL(string: openURL) { UIApplication.shared.open(url) }
    }
}
