import SwiftUI

struct UserView: View {
    let keyType: KeyType
    let licenseKey: String
    let expiresAt: String
    let onLogout: () -> Void

    private var maskedKey: String {
        guard licenseKey.count >= 9 else { return licenseKey }
        return String(licenseKey.prefix(5)) + "****-****"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                infoCard
                adminCard
                logoutButton
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .background(CyberGridBackground().ignoresSafeArea())
    }

    // MARK: - User License Details

    private var infoCard: some View {
        CyberCard {
            VStack(alignment: .leading, spacing: 14) {
                CyberSectionHeader(title: "THÔNG TIN TÀI KHOẢN", accent: CyberTheme.cyberCyan)
                HStack {
                    TierBadge(tier: keyType)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(CyberTheme.cyberGreen).frame(width: 8, height: 8)
                            .cyberGlow(CyberTheme.cyberGreen, radius: 4, opacity: 0.7)
                        Text("Đã đồng bộ")
                            .font(.caption)
                            .foregroundStyle(CyberTheme.cyberGreen)
                    }
                }
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "LICENSE KEY", value: maskedKey)
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "LOẠI TÀI KHOẢN", value: keyType.rawValue.uppercased())
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "NGÀY HẾT HẠN", value: (expiresAt.isEmpty || expiresAt == "null") ? "Vĩnh viễn" : expiresAt)
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "HWID", value: getHWID())
                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))
                CopyableRow(label: "HỆ THỐNG", value: "Plexus Cloud Auth v2.1")
            }
        }
    }

    // MARK: - Admin Infopanel

    private var adminCard: some View {
        CyberCard(borderColor: CyberTheme.cyberCyan) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(CyberTheme.cyberCyan)
                    Text("QUẢN TRỊ VIÊN HỆ THỐNG")
                        .font(.system(.subheadline, design: .rounded).weight(.heavy))
                        .foregroundStyle(CyberTheme.textPrimary)
                        .tracking(1.5)
                }
                Text("Hỗ trợ 24/7 & Kích hoạt bản quyền")
                    .font(.caption)
                    .foregroundStyle(CyberTheme.textSecondary)

                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(colors: [CyberTheme.cyberPurple, CyberTheme.cyberCyan],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: 52, height: 52)
                            .overlay(Circle().stroke(CyberTheme.cyberGold, lineWidth: 2))
                            .cyberGlow(CyberTheme.cyberGold, radius: 6, opacity: 0.5)
                        Text("VA")
                            .font(.system(.title3, design: .monospaced).weight(.heavy))
                            .foregroundStyle(CyberTheme.textPrimary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Việt Anh")
                            .font(.system(.subheadline, design: .rounded).weight(.bold))
                            .foregroundStyle(CyberTheme.textPrimary)
                        Text("Plexus Developer & Distributor")
                            .font(.caption)
                            .foregroundStyle(CyberTheme.textSecondary)
                    }
                    Spacer()
                }

                Divider().overlay(CyberTheme.textSecondary.opacity(0.2))

                adminRow(icon: "bubble.left.fill",
                         title: "Zalo Admin",
                         subtitle: "SDT: 0377045762",
                         buttonTitle: "MỞ & COPY",
                         tint: CyberTheme.cyberGold) {
                    UIPasteboard.general.string = "0377045762"
                    ToastManager.shared.show("Đã sao chép SĐT Zalo Việt Anh!", type: .success)
                    if let url = URL(string: "tel:0377045762") { UIApplication.shared.open(url) }
                }

                adminRow(icon: "paperplane.fill",
                         title: "Telegram Admin",
                         subtitle: "Username: @trnmnhkh",
                         buttonTitle: "LIÊN HỆ",
                         tint: CyberTheme.cyberCyan) {
                    UIPasteboard.general.string = "@trnmnhkh"
                    ToastManager.shared.show("Đã sao chép Telegram Việt Anh!", type: .success)
                    if let url = URL(string: "https://t.me/trnmnhkh") { UIApplication.shared.open(url) }
                }
            }
        }
    }

    private func adminRow(icon: String, title: String, subtitle: String,
                          buttonTitle: String, tint: Color, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(CyberTheme.darkBorder)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                    .foregroundStyle(CyberTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(CyberTheme.textSecondary)
            }
            Spacer()
            Button {
                Haptics.medium()
                action()
            } label: {
                Text(buttonTitle)
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(CyberTheme.cyberBgTop)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(tint)
                    .clipShape(Capsule())
                    .cyberGlow(tint, radius: 5, opacity: 0.5)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Logout

    private var logoutButton: some View {
        Button {
            Haptics.medium()
            onLogout()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "power")
                Text("ĐĂNG XUẤT HỆ THỐNG PLEXUS")
                    .font(.system(.headline, design: .rounded).weight(.heavy))
                    .tracking(1.5)
            }
            .foregroundStyle(CyberTheme.dangerRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CyberTheme.darkBorder)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(CyberTheme.dangerRed, lineWidth: 1.5)
            )
            .cyberGlow(CyberTheme.dangerRed, radius: 10, opacity: 0.5)
        }
        .buttonStyle(.plain)
    }
}
