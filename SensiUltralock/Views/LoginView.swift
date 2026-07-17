import SwiftUI
import UIKit

struct LoginView: View {
    let dim: ViewDimensions
    let onLoginSuccess: (Bool, String, String, KeyType) -> Void
    var notificationMessage: String = ""

    @State private var keyInput = ""
    @State private var isConnecting = false
    @State private var errorMessage = ""
    @State private var showSupportDialog = false
    @State private var supportChannelSelected = ""
    @State private var supportURL: URL? = nil
    @State private var showEffects = true
    @FocusState private var isKeyFieldFocused: Bool

    private var w: CGFloat { dim.w }
    private var h: CGFloat { dim.h }
    private var scale: CGFloat { dim.scale }
    private var safeTop: CGFloat { dim.safeTop }
    private var safeBottom: CGFloat { dim.safeBottom }

    var body: some View {
        ZStack(alignment: .top) {
            CyberBg.ignoresSafeArea()
            AnimatedGridBackground(color: CyberYellow, opacity: 0.06, animate: true)
                .ignoresSafeArea()
            if showEffects {
                FloatingParticles(count: 20, color: CyberYellow, speed: 0.5)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                ScanlineOverlay(opacity: 0.02)
                    .ignoresSafeArea()
            }

            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        spacer(safeTop + h * 0.03)

                        avatarSection
                        spacer(h * 0.018)
                        brandingSection
                        spacer(h * 0.016)
                        if !notificationMessage.isEmpty {
                            HStack(spacing: 8) {
                                Text("⚠️").font(.system(size: 12))
                                Text(notificationMessage)
                                    .font(.system(size: max(10, 11 * scale), weight: .semibold))
                                    .foregroundColor(Color(hexARGB: 0xFFFFD54F))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(h * 0.014)
                            .background(Color(hexARGB: 0x22FFD700))
                            .cornerRadius(max(10, 12 * scale))
                            .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(Color(hexARGB: 0x44FFD700), lineWidth: 1))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        spacer(h * 0.016)
                        authCard
                        spacer(h * 0.02)
                        supportSection

                        spacer(safeBottom + h * 0.03)
                            .id("bottomSpacer")
                    }
                    .padding(.horizontal, w * 0.05)
                    .frame(minHeight: h + safeTop + safeBottom)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .modifier(KeyboardDismissModifier())
                .onChange(of: isKeyFieldFocused) { focused in
                    if focused {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation { scrollProxy.scrollTo("keyField", anchor: .center) }
                        }
                    }
                }
            }

            // Effects toggle
            VStack {
                spacer(safeTop + 8)
                HStack {
                    Spacer()
                    Button(action: { showEffects.toggle() }) {
                        Image(systemName: showEffects ? "eye.fill" : "eye.slash")
                            .font(.system(size: 10))
                            .foregroundColor(CyberTextSecondary)
                            .padding(6)
                            .background(CyberDarkBg.opacity(0.6))
                            .cornerRadius(6)
                    }
                    .padding(.trailing, 16)
                }
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .preferredColorScheme(.dark)
        .alert("HỖ TRỢ THÀNH VIÊN", isPresented: $showSupportDialog) {
            Button("LIÊN HỆ NGAY") {
                showSupportDialog = false
                if let url = supportURL { UIApplication.shared.open(url, options: [:]) }
            }
            Button("ĐÓNG", role: .cancel) { showSupportDialog = false }
        } message: {
            Text("Bạn đang kết nối tới:\n\(supportChannelSelected)\n\nNhấn Liên hệ để được hỗ trợ.")
        }
    }

    // MARK: - Avatar
    private var avatarSection: some View {
        Image("Avatar")
            .resizable()
            .scaledToFill()
            .frame(width: w * 0.2, height: w * 0.2)
            .clipShape(Circle())
            .overlay(Circle().stroke(CyberYellow, lineWidth: max(1.5, scale)))
            .shadow(color: CyberYellow.opacity(0.4), radius: w * 0.03)
    }

    // MARK: - Branding
    private var brandingSection: some View {
        VStack(spacing: h * 0.004) {
            GlitchText(
                text: "Sensi Ultralock",
                size: max(22, 30 * scale),
                color: .white,
                glitchColor1: .red,
                glitchColor2: .cyan,
                intensity: 0.12,
                weight: .black
            )
            .shadow(color: CyberYellow.opacity(0.6), radius: w * 0.03)
            .multilineTextAlignment(.center)

            Text("HỆ THỐNG TỐI ƯU CẤU HÌNH FREE FIRE")
                .font(.system(size: max(9, 10 * scale), design: .monospaced).weight(.bold))
                .foregroundColor(CyberTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Auth Card
    private var authCard: some View {
        VStack(spacing: h * 0.018) {
            Text("KÍCH HOẠT HỆ THỐNG PLEXUS")
                .font(.system(size: max(12, 13 * scale), weight: .black))
                .foregroundColor(.white)
                .kerning(1)

            TextField("", text: $keyInput, prompt: Text("Mã kích hoạt VIP (License Key)").foregroundColor(CyberTextSecondary))
                .font(.system(size: max(12, 13 * scale)))
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isKeyFieldFocused)
                .id("keyField")
                .padding(w * 0.04)
                .background(CyberDarkBg)
                .cornerRadius(max(12, 14 * scale))
                .overlay(
                    RoundedRectangle(cornerRadius: max(12, 14 * scale))
                        .stroke(keyInput.isEmpty ? CyberDarkBorder : CyberYellow, lineWidth: 1)
                )

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.system(size: max(10, 11 * scale), weight: .bold))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .transition(.opacity)
            }

            Button(action: loginAction) {
                HStack {
                    if isConnecting {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .black))
                    }
                    Text(isConnecting ? "ĐANG XÁC THỰC..." : "XÁC THỰC NGAY")
                        .font(.system(size: max(12, 13 * scale), weight: .black))
                        .foregroundColor(.black)
                        .kerning(1)
                }
                .frame(maxWidth: .infinity)
                .frame(height: max(44, 48 * scale))
                .background(
                    LinearGradient(colors: [CyberYellow, CyberAmber],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(max(12, 14 * scale))
                .neonGlow(color: CyberYellow, radius: 8, intensity: 0.5)
            }
            .disabled(isConnecting)
            .scaleEffect(isConnecting ? 0.97 : 1.0)
            .animation(.spring(response: 0.3), value: isConnecting)

            Button(action: { keyInput = "PLEXUS-VIP-TEST" }) {
                Text("Nhấp để điền mã Key thử nghiệm miễn phí")
                    .font(.system(size: max(10, 11 * scale), weight: .bold))
                    .foregroundColor(CyberAmber)
            }

            VStack(spacing: h * 0.006) {
                Text("HƯỚNG DẪN KÍCH HOẠT PLEXUS KEY")
                    .font(.system(size: max(9, 10 * scale), weight: .bold))
                    .foregroundColor(CyberIceYellow)
                    .kerning(0.8)
                Text("Nhập mã key bản quyền Plexus để kích hoạt. Liên hệ admin qua các kênh bên dưới để nhận key miễn phí hoặc báo lỗi.")
                    .font(.system(size: max(9, 10 * scale)))
                    .foregroundColor(CyberTextSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(w * 0.03)
            .frame(maxWidth: .infinity)
            .background(CyberDarkBg.opacity(0.5))
            .cornerRadius(max(10, 12 * scale))
            .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(CyberDarkBorder, lineWidth: 1))
        }
        .padding(w * 0.045)
        .background(CyberCardBg)
        .cornerRadius(max(18, 22 * scale))
        .overlay(RoundedRectangle(cornerRadius: max(18, 22 * scale)).stroke(CyberDarkBorder, lineWidth: 1.2))
        .shadow(color: CyberYellow.opacity(0.2), radius: w * 0.03)
    }

    // MARK: - Support Section
    private var supportSection: some View {
        VStack(spacing: h * 0.015) {
            Text("KÊNH LIÊN HỆ & BÁO LỖI HỖ TRỢ")
                .font(.system(size: max(10, 11 * scale), weight: .bold))
                .foregroundColor(CyberTextSecondary.opacity(0.8))
                .kerning(2)

            HStack(spacing: w * 0.03) {
                supportButton(
                    icon: "💬",
                    label: "Telegram",
                    channel: "Telegram Admin (@SensiUltralock_VIP)",
                    url: "https://t.me/SensiUltralock_VIP"
                )
                supportButton(
                    icon: "📞",
                    label: "Zalo Support",
                    channel: "Zalo Support (098.334.88xx)",
                    url: "tel:09833488xx"
                )
            }

            Button(action: {
                supportChannelSelected = "Cộng Đồng Game Thủ Sensi Ultralock Zalo"
                supportURL = URL(string: "https://zalo.me/g/sensiultralock")
                showSupportDialog = true
            }) {
                Text("Tham gia Group Zalo Chia Sẻ Kinh Nghiệm")
                    .font(.system(size: max(10, 11 * scale), weight: .semibold))
                    .foregroundColor(CyberIceYellow)
                    .padding(.horizontal, w * 0.04)
                    .padding(.vertical, h * 0.01)
                    .background(Color(hexARGB: 0x22BD00FF))
                    .cornerRadius(max(12, 14 * scale))
                    .overlay(RoundedRectangle(cornerRadius: max(12, 14 * scale)).stroke(CyberYellow.opacity(0.3), lineWidth: 1))
            }
        }
    }

    private func supportButton(icon: String, label: String, channel: String, url: String) -> some View {
        Button(action: {
            supportChannelSelected = channel
            supportURL = URL(string: url)
            showSupportDialog = true
        }) {
            HStack(spacing: w * 0.012) {
                Circle().fill(CyberYellow.opacity(0.2)).frame(width: max(8, 10 * scale), height: max(8, 10 * scale))
                    .overlay(Text(icon).font(.system(size: max(8, 9 * scale))))
                Text(label).font(.system(size: max(11, 12 * scale), weight: .bold)).foregroundColor(.white)
            }
            .padding(.horizontal, w * 0.03)
            .padding(.vertical, h * 0.01)
            .background(CyberMediumBg)
            .cornerRadius(max(10, 12 * scale))
            .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(CyberYellow.opacity(0.5), lineWidth: 1))
        }
    }

    private func spacer(_ height: CGFloat) -> some View {
        Color.clear.frame(height: height)
    }

    private func loginAction() {
        let key = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            errorMessage = "Vui lòng nhập Mã kích hoạt (VIP Key)!"
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
}

struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.1, *) {
            content.scrollDismissesKeyboard(.interactively)
        } else if #available(iOS 15, *) {
            content
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
        } else {
            content
        }
    }
}
