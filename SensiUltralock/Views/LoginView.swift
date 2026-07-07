import SwiftUI

struct LoginView: View {
    let onLoginSuccess: (Bool, String, String, KeyType) -> Void

    @State private var keyInput = ""
    @State private var isConnecting = false
    @State private var errorMessage = ""
    @State private var showSupportDialog = false
    @State private var supportChannelSelected = ""

    var body: some View {
        ZStack {
            // Cyber Grid Background
            GeometryReader { geometry in
                Canvas { context, size in
                    let gridSpacing: CGFloat = 44
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
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // Logo
                    Image(systemName: "gamecontroller.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(CyberYellow, lineWidth: 2))
                        .shadow(color: CyberYellow.opacity(0.5), radius: 16)
                        .foregroundColor(CyberYellow)

                    Spacer().frame(height: 24)

                    // App Title
                    Text("Sensi Ultralock")
                        .font(.custom("Georgia", size: 32))
                        .italic()
                        .fontWeight(.black)
                        .foregroundColor(.white)
                        .shadow(color: CyberYellow.opacity(0.65), radius: 14)

                    Text("HỆ THỐNG TỐI ƯU CẤU HÌNH FREE FIRE")
                        .font(.system(size: 11, design: .monospaced))
                        .fontWeight(.bold)
                        .foregroundColor(CyberTextSecondary)
                        .padding(.top, 4)

                    Spacer().frame(height: 32)

                    // Main Card
                    VStack(spacing: 18) {
                        Text("KÍCH HOẠT HỆ THỐNG PLEXUS")
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(.white)
                            .kerning(1.2)

                        // Key Input
                        TextField("", text: $keyInput, prompt: Text("Mã kích hoạt VIP (License Key)").foregroundColor(CyberTextSecondary))
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(CyberDarkBg)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(keyInput.isEmpty ? CyberDarkBorder : CyberYellow, lineWidth: 1)
                            )

                        // Error
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }

                        // Login Button
                        Button(action: loginAction) {
                            HStack {
                                if isConnecting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                Text(isConnecting ? "ĐANG XÁC THỰC..." : "XÁC THỰC NGAY")
                                    .font(.system(size: 13, weight: .black))
                                    .foregroundColor(.white)
                                    .kerning(1)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(CyberYellow)
                            .cornerRadius(16)
                            .shadow(color: CyberYellow.opacity(0.4), radius: 8)
                        }
                        .disabled(isConnecting)

                        // Quick test key
                        Button(action: { keyInput = "PLEXUS-VIP-TEST" }) {
                            Text("Nhấp để điền mã Key thử nghiệm miễn phí")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(CyberAmber)
                        }

                        // Guide card
                        VStack(spacing: 6) {
                            Text("HƯỚNG DẪN KÍCH HOẠT PLEXUS KEY")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(CyberIceYellow)
                                .kerning(0.8)
                            Text("Vui lòng nhập mã key bản quyền Plexus để kích hoạt ứng dụng tối ưu. Bạn có thể sử dụng các kênh hỗ trợ bên dưới để nhận mã key miễn phí hoặc báo lỗi kích hoạt.")
                                .font(.system(size: 10))
                                .foregroundColor(CyberTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(CyberDarkBg.opacity(0.5))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(CyberDarkBorder, lineWidth: 1))
                    }
                    .padding(20)
                    .background(CyberCardBg)
                    .cornerRadius(24)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(CyberDarkBorder, lineWidth: 1.2))
                    .shadow(color: CyberYellow.opacity(0.3), radius: 16)

                    Spacer().frame(height: 24)

                    // Contact Section
                    Text("KÊNH LIÊN HỆ & BÁO LỖI HỖ TRỢ")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(CyberTextSecondary.opacity(0.8))
                        .kerning(2)

                    Spacer().frame(height: 12)

                    HStack(spacing: 16) {
                        // Telegram
                        Button(action: {
                            supportChannelSelected = "Telegram Admin (@SensiUltralock_VIP)"
                            showSupportDialog = true
                        }) {
                            HStack(spacing: 6) {
                                Circle().fill(Color(hexARGB: 0xFF00C3FF)).frame(width: 10, height: 10)
                                Text("Telegram").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(CyberMediumBg)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(CyberYellow.opacity(0.6), lineWidth: 1))
                        }

                        // Zalo
                        Button(action: {
                            supportChannelSelected = "Zalo Support (098.334.88xx)"
                            showSupportDialog = true
                        }) {
                            HStack(spacing: 6) {
                                Circle().fill(Color(hexARGB: 0xFF2F80ED)).frame(width: 10, height: 10)
                                Text("Zalo Support").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(CyberMediumBg)
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(CyberYellow.opacity(0.6), lineWidth: 1))
                        }
                    }

                    Spacer().frame(height: 12)

                    // Zalo Group
                    Button(action: {
                        supportChannelSelected = "Cộng Đồng Game Thủ Sensi Ultralock Zalo"
                        showSupportDialog = true
                    }) {
                        Text("Tham gia Group Zalo Chia Sẻ Kinh Nghiệm 💬")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(CyberIceYellow)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(hexARGB: 0x22BD00FF))
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(CyberYellow.opacity(0.3), lineWidth: 1))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .preferredColorScheme(.dark)
        .alert("HỖ TRỢ THÀNH VIÊN", isPresented: $showSupportDialog) {
            Button("LIÊN HỆ NGAY") {
                showSupportDialog = false
                if let url = URL(string: "https://t.me/telegram") {
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
