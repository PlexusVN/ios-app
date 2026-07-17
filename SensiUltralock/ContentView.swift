import SwiftUI

struct ContentView: View {
    @State private var authState: AuthState = .loading
    @State private var isVipUser = false
    @State private var keyType: KeyType = .basic
    @State private var licenseKey = ""
    @State private var expiresAt = ""
    @State private var serverConnected = true
    @State private var initDone = false
    @State private var loginNotification = ""

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let scale = min(max(w / 375, 0.75), 1.5)
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            let dim = ViewDimensions(w: w, h: h, scale: scale, safeTop: safeTop, safeBottom: safeBottom)

            ZStack {
                switch authState {
                case .loading:
                    LoadingView(dim: dim)
                case .unauthenticated:
                    LoginView(dim: dim, notificationMessage: loginNotification, onLoginSuccess: { isVip, key, expiry, type in
                        saveCredentials(key: key, type: type.rawValue, expiresAt: expiry)
                        ToastManager.shared.show("Kích hoạt bản quyền thành công!", type: .success)
                        isVipUser = isVip
                        keyType = type
                        licenseKey = key
                        expiresAt = expiry
                        loginNotification = ""
                        authState = .authenticated
                    })
                case .authenticated:
                    DashboardView(
                        dim: dim,
                        isVip: isVipUser,
                        keyType: keyType,
                        licenseKey: licenseKey,
                        expiresAt: expiresAt,
                        onLogout: {
                            clearSavedCredentials()
                            ToastManager.shared.show("Đã đăng xuất tài khoản!", type: .warning)
                            licenseKey = ""
                            expiresAt = ""
                            isVipUser = false
                            keyType = .basic
                            loginNotification = ""
                            authState = .unauthenticated
                        }
                    )
                }

                // Server disconnected overlay
                if !serverConnected && initDone {
                    serverNotifOverlay
                }
            }
            .modifier(ToastModifier(manager: ToastManager.shared, bottomPadding: dim.safeBottom))
        }
        .preferredColorScheme(.dark)
        .task {
            await performStartup()
        }
        .onChange(of: authState) { newValue in
            if newValue == .authenticated {
                startBackgroundMonitors()
            }
        }
    }

    // MARK: - Startup Logic

    private func performStartup() async {
        // Step 1: Check server health
        let connected = await checkServerConnection()
        await MainActor.run { serverConnected = connected }

        // Step 2: Load saved credentials
        let saved = loadSavedCredentials()

        // Step 3: Auto-login if possible
        if let creds = saved, connected {
            let result = await verifyLicenseKey(key: creds.key)
            if let r = result, r.success, r.status == "valid" {
                await MainActor.run {
                    licenseKey = creds.key
                    expiresAt = creds.expiresAt
                    keyType = computeKeyType(from: creds.type)
                    isVipUser = keyType == .vip
                    authState = .authenticated
                    initDone = true
                }
                startHealthPolling()
                return
            } else {
                clearSavedCredentials()
                await MainActor.run {
                    loginNotification = "Key đã hết hạn hoặc bị thu hồi. Vui lòng đăng nhập lại."
                }
            }
        }

        await MainActor.run {
            initDone = true
            authState = .unauthenticated
        }

        startHealthPolling()
    }

    private func startHealthPolling() {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                let connected = await checkServerConnection()
                await MainActor.run { serverConnected = connected }
            }
        }
    }

    private func startBackgroundMonitors() {
        // Re-verify key every 60s
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                guard authState == .authenticated else { break }
                let result = await verifyLicenseKey(key: licenseKey)
                if result?.success != true || result?.status != "valid" {
                    await MainActor.run {
                        clearSavedCredentials()
                        authState = .unauthenticated
                    }
                }
            }
        }
    }

    // MARK: - Server Notification Overlay

    private var serverNotifOverlay: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Text("⚠️")
                        .font(.system(size: 30))
                }

                Text("MẤT KẾT NỐI MÁY CHỦ")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.red)
                    .customTracking(1.5)

                Text("Không thể kết nối đến máy chủ Plexus.\nVui lòng kiểm tra đường truyền internet\nvà thử lại.")
                    .font(.system(size: 13))
                    .foregroundColor(CyberTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                Button(action: {
                    Task {
                        let connected = await checkServerConnection()
                        await MainActor.run { serverConnected = connected }
                    }
                }) {
                    Text("THỬ LẠI")
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
            }
            .padding(24)
            .background(CyberCardBg)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.red.opacity(0.5), lineWidth: 1))
            .padding(.horizontal, 40)
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
    }
}
