import SwiftUI
import UIKit

struct LoginView: View {
    let onLoginSuccess: (Bool, String, String, KeyType) -> Void

    @State private var keyInput = ""
    @State private var isConnecting = false
    @State private var errorMessage = ""
    @State private var showSupportDialog = false
    @State private var supportChannelSelected = ""
    @State private var supportURL: URL? = nil
    @FocusState private var isKeyFieldFocused: Bool

    private var screenSize: CGSize { UIScreen.main.bounds.size }
    private var w: CGFloat { screenSize.width }
    private var h: CGFloat { screenSize.height }
    private var scale: CGFloat { min(max(w / 375, 0.75), 1.5) }

    var body: some View {
        ZStack {
            Canvas { context, size in
                let gridSpacing: CGFloat = max(28, w * 0.12)
                for x in stride(from: 0, through: size.width, by: gridSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(CyberYellow.opacity(0.08)), lineWidth: 1)
                }
                for y in stride(from: 0, through: size.height, by: gridSpacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(CyberYellow.opacity(0.08)), lineWidth: 1)
                }
            }

            ScrollViewReader { scrollProxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer(minLength: h * 0.06)

                        Image("Avatar")
                            .resizable()
                            .scaledToFill()
                            .frame(width: w * 0.26, height: w * 0.26)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(CyberYellow, lineWidth: max(1.5, scale)))
                            .shadow(color: CyberYellow.opacity(0.5), radius: w * 0.04)

                        Spacer(minLength: h * 0.025)

                        Text("Sensi Ultralock")
                            .font(.custom("Georgia", size: max(22, 32 * scale)))
                            .italic()
                            .fontWeight(.black)
                            .foregroundColor(.white)
                            .shadow(color: CyberYellow.opacity(0.65), radius: w * 0.035)
                            .multilineTextAlignment(.center)

                        Text("HỆ THỐNG TỐI ƯU CẤU HÌNH FREE FIRE")
                            .font(.system(size: max(9, 11 * scale), design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(CyberTextSecondary)
                            .padding(.top, h * 0.006)
                            .multilineTextAlignment(.center)

                        Spacer(minLength: h * 0.035)

                        VStack(spacing: h * 0.022) {
                            Text("KÍCH HOẠT HỆ THỐNG PLEXUS")
                                .font(.system(size: max(12, 14 * scale), weight: .black))
                                .foregroundColor(.white)
                                .kerning(1.2)

                            TextField("", text: $keyInput, prompt: Text("Mã kích hoạt VIP (License Key)").foregroundColor(CyberTextSecondary))
                                .font(.system(size: max(12, 14 * scale)))
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .focused($isKeyFieldFocused)
                                .id("keyField")
                                .padding(w * 0.04)
                                .background(CyberDarkBg)
                                .cornerRadius(max(12, 16 * scale))
                                .overlay(
                                    RoundedRectangle(cornerRadius: max(12, 16 * scale))
                                        .stroke(keyInput.isEmpty ? CyberDarkBorder : CyberYellow, lineWidth: 1)
                                )

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: max(10, 11 * scale), weight: .bold))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }

                            Button(action: loginAction) {
                                HStack {
                                    if isConnecting {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    }
                                    Text(isConnecting ? "ĐANG XÁC THỰC..." : "XÁC THỰC NGAY")
                                        .font(.system(size: max(12, 13 * scale), weight: .black))
                                        .foregroundColor(.white)
                                        .kerning(1)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: max(44, 52 * scale))
                                .background(CyberYellow)
                                .cornerRadius(max(12, 16 * scale))
                                .shadow(color: CyberYellow.opacity(0.4), radius: w * 0.02)
                            }
                            .disabled(isConnecting)

                            Button(action: { keyInput = "PLEXUS-VIP-TEST" }) {
                                Text("Nhấp để điền mã Key thử nghiệm miễn phí")
                                    .font(.system(size: max(10, 11 * scale), weight: .bold))
                                    .foregroundColor(CyberAmber)
                            }

                            VStack(spacing: h * 0.008) {
                                Text("HƯỚNG DẪN KÍCH HOẠT PLEXUS KEY")
                                    .font(.system(size: max(9, 10 * scale), weight: .bold))
                                    .foregroundColor(CyberIceYellow)
                                    .kerning(0.8)
                                Text("Vui lòng nhập mã key bản quyền Plexus để kích hoạt ứng dụng tối ưu. Bạn có thể sử dụng các kênh hỗ trợ bên dưới để nhận mã key miễn phí hoặc báo lỗi kích hoạt.")
                                    .font(.system(size: max(9, 10 * scale)))
                                    .foregroundColor(CyberTextSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(w * 0.03)
                            .frame(maxWidth: .infinity)
                            .background(CyberDarkBg.opacity(0.5))
                            .cornerRadius(max(10, 12 * scale))
                            .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(CyberDarkBorder, lineWidth: 1))
                        }
                        .padding(w * 0.05)
                        .background(CyberCardBg)
                        .cornerRadius(max(18, 24 * scale))
                        .overlay(RoundedRectangle(cornerRadius: max(18, 24 * scale)).stroke(CyberDarkBorder, lineWidth: 1.2))
                        .shadow(color: CyberYellow.opacity(0.3), radius: w * 0.04)

                        Spacer(minLength: h * 0.03)

                        Text("KÊNH LIÊN HỆ & BÁO LỖI HỖ TRỢ")
                            .font(.system(size: max(10, 11 * scale), weight: .bold))
                            .foregroundColor(CyberTextSecondary.opacity(0.8))
                            .kerning(2)

                        Spacer(minLength: h * 0.015)

                        HStack(spacing: w * 0.04) {
                            Button(action: {
                                supportChannelSelected = "Telegram Admin (@SensiUltralock_VIP)"
                                supportURL = URL(string: "https://t.me/SensiUltralock_VIP")
                                showSupportDialog = true
                            }) {
                                HStack(spacing: w * 0.015) {
                                    Circle().fill(Color(hexARGB: 0xFF00C3FF)).frame(width: max(8, 10 * scale), height: max(8, 10 * scale))
                                    Text("Telegram").font(.system(size: max(11, 12 * scale), weight: .bold)).foregroundColor(.white)
                                }
                                .padding(.horizontal, w * 0.035)
                                .padding(.vertical, h * 0.012)
                                .background(CyberMediumBg)
                                .cornerRadius(max(10, 12 * scale))
                                .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(CyberYellow.opacity(0.6), lineWidth: 1))
                            }

                            Button(action: {
                                supportChannelSelected = "Zalo Support (098.334.88xx)"
                                supportURL = URL(string: "tel:09833488xx")
                                showSupportDialog = true
                            }) {
                                HStack(spacing: w * 0.015) {
                                    Circle().fill(Color(hexARGB: 0xFF2F80ED)).frame(width: max(8, 10 * scale), height: max(8, 10 * scale))
                                    Text("Zalo Support").font(.system(size: max(11, 12 * scale), weight: .bold)).foregroundColor(.white)
                                }
                                .padding(.horizontal, w * 0.035)
                                .padding(.vertical, h * 0.012)
                                .background(CyberMediumBg)
                                .cornerRadius(max(10, 12 * scale))
                                .overlay(RoundedRectangle(cornerRadius: max(10, 12 * scale)).stroke(CyberYellow.opacity(0.6), lineWidth: 1))
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Spacer(minLength: h * 0.015)

                        Button(action: {
                            supportChannelSelected = "Cộng Đồng Game Thủ Sensi Ultralock Zalo"
                            supportURL = URL(string: "https://zalo.me/g/sensiultralock")
                            showSupportDialog = true
                        }) {
                            Text("Tham gia Group Zalo Chia Sẻ Kinh Nghiệm 💬")
                                .font(.system(size: max(10, 11 * scale), weight: .semibold))
                                .foregroundColor(CyberIceYellow)
                                .padding(.horizontal, w * 0.05)
                                .padding(.vertical, h * 0.01)
                                .background(Color(hexARGB: 0x22BD00FF))
                                .cornerRadius(max(12, 16 * scale))
                                .overlay(RoundedRectangle(cornerRadius: max(12, 16 * scale)).stroke(CyberYellow.opacity(0.3), lineWidth: 1))
                        }

                        Spacer(minLength: h * 0.05)
                            .id("bottomSpacer")
                    }
                    .padding(.horizontal, w * 0.06)
                    .frame(minHeight: h)
                }
                .modifier(KeyboardDismissModifier())
                .onChange(of: isKeyFieldFocused) { focused in
                    if focused {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                scrollProxy.scrollTo("keyField", anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .alert("HỖ TRỢ THÀNH VIÊN", isPresented: $showSupportDialog) {
            Button("LIÊN HỆ NGAY") {
                showSupportDialog = false
                if let url = supportURL {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            Button("ĐÓNG", role: .cancel) { showSupportDialog = false }
        } message: {
            Text("Bạn đang thực hiện kết nối tới kênh hỗ trợ:\n\(supportChannelSelected)\n\nNhấn nút Liên hệ hoặc lưu số điện thoại admin để được kích hoạt mã VIP miễn phí ngay lập tức.")
        }
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
                    KeychainManager.save(key: "saved_key", value: key)
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
        if #available(iOS 16, *) {
            content.scrollDismissesKeyboard(.interactively)
        } else {
            content
        }
    }
}
