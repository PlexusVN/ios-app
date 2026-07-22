import SwiftUI

struct UserView: View {
    @ObservedObject var viewModel: AppViewModel

    private var maskedKey: String {
        let k = viewModel.keyInput
        guard k.count >= 9 else { return k }
        return String(k.prefix(5)) + "****-****"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                infoCard
                adminCard
                logoutButton
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 20)
        }
        .scrollIndicators(.hidden)
        .background(CyberGridBackground().ignoresSafeArea())
    }

    // MARK: - User License Details

    private var infoCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 10) {
                CyberSectionHeader(title: "THÔNG TIN TÀI KHOẢN", accent: CyberTheme.cyberCyan)
                HStack {
                    TierBadge(tier: viewModel.currentTier)
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(CyberTheme.cyberGreen).frame(width: 6, height: 6)
                            .cyberGlow(CyberTheme.cyberGreen, radius: 3, opacity: 0.6)
                        Text("Đã đồng bộ")
                            .font(.caption2)
                            .foregroundStyle(CyberTheme.cyberGreen)
                    }
                }
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "LICENSE KEY", value: maskedKey)
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "LOẠI TÀI KHOẢN", value: viewModel.currentTier.rawValue.uppercased())
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "NGÀY HẾT HẠN", value: expiresDisplay)
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "HWID", value: viewModel.hwid)
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "HỆ THỐNG", value: "Nexora Cloud Auth v2.1")
            }
        }
    }

    private var expiresDisplay: String {
        let expiry = viewModel.savedExpiresAt()
        return (expiry.isEmpty || expiry == "null") ? "Vĩnh viễn" : expiry
    }

    // MARK: - Admin Infopanel

    private var adminCard: some View {
        CyberCard(borderColor: CyberTheme.cyberCyan) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 12))
                        .foregroundStyle(CyberTheme.cyberCyan)
                    Text("QUẢN TRỊ VIÊN HỆ THỐNG")
                        .font(.system(.footnote, design: .rounded).weight(.heavy))
                        .foregroundStyle(CyberTheme.textPrimary)
                        .tracking(1)
                }
                Text("Hỗ trợ 24/7 & Kích hoạt bản quyền")
                    .font(.caption2)
                    .foregroundStyle(CyberTheme.textSecondary)

                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [CyberTheme.cyberPurple, CyberTheme.cyberCyan],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 42, height: 42)
                            .overlay(Circle().stroke(CyberTheme.cyberGold, lineWidth: 1.5))
                            .cyberGlow(CyberTheme.cyberGold, radius: 4, opacity: 0.4)
                        Text("GL")
                            .font(.system(.callout, design: .monospaced).weight(.heavy))
                            .foregroundStyle(CyberTheme.textPrimary)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Gia Lượng")
                            .font(.system(.footnote, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.textPrimary)
                        Text("Nexora Developer & Distributor")
                            .font(.caption2)
                            .foregroundStyle(CyberTheme.textSecondary)
                    }
                    Spacer()
                }

                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))

                adminRow(icon: "bubble.left.fill",
                         title: "Zalo Admin",
                         subtitle: "SDT: 0862164381",
                         buttonTitle: "MỞ & COPY",
                         tint: CyberTheme.cyberGold) {
                    UIPasteboard.general.string = "0862164381"
                    viewModel.showToast("Đã sao chép SĐT Zalo Gia Lượng!")
                    if let url = URL(string: "tel:0862164381") { UIApplication.shared.open(url) }
                }

                adminRow(icon: "paperplane.fill",
                         title: "Telegram Admin",
                         subtitle: "Username: @trnmnhkh",
                         buttonTitle: "LIÊN HỆ",
                         tint: CyberTheme.cyberCyan) {
                    UIPasteboard.general.string = "@trnmnhkh"
                    viewModel.showToast("Đã sao chép Telegram Gia Lượng!")
                    if let url = URL(string: "https://t.me/trnmnhkh") { UIApplication.shared.open(url) }
                }
            }
        }
    }

    private func adminRow(icon: String, title: String, subtitle: String,
                          buttonTitle: String, tint: Color, action: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(CyberTheme.darkBorder)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(.footnote, design: .rounded).weight(.bold))
                    .foregroundStyle(CyberTheme.textPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(CyberTheme.textSecondary)
            }
            Spacer()
            Button {
                Haptics.medium()
                action()
            } label: {
                Text(buttonTitle)
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(CyberTheme.cyberBgTop)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(tint)
                    .clipShape(Capsule())
                    .cyberGlow(tint, radius: 3, opacity: 0.4)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 3)
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            Haptics.medium()
            viewModel.logout()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "power")
                    .font(.system(size: 12))
                Text("ĐĂNG XUẤT HỆ THỐNG NEXORA")
                    .font(.system(.subheadline, design: .rounded).weight(.heavy))
                    .tracking(1)
            }
            .foregroundStyle(CyberTheme.dangerRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(CyberTheme.darkBorder)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(CyberTheme.dangerRed, lineWidth: 1.2)
            )
            .cyberGlow(CyberTheme.dangerRed, radius: 8, opacity: 0.4)
        }
        .buttonStyle(.plain)
    }
}
