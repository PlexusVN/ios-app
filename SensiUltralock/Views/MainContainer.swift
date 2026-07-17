import SwiftUI

struct MainContainer: View {
    @State private var authState: AuthState = .loading
    @State private var isVipUser = false
    @State private var keyType: KeyType = .basic
    @State private var licenseKey = ""
    @State private var expiresAt = ""
    @State private var serverConnected = true
    @State private var initDone = false
    @State private var loginNotification = ""
    @State private var selectedTab: Int = 0
    @State private var dpiFactor: Double = 1.0
    @State private var recoilReduction: Double = 20.0
    @State private var responseMs: Int = 1
    @State private var activeStates: Set<String> = []

    @StateObject private var toastManager = ToastManager.shared

    var body: some View {
        ZStack {
            CyberTheme.bgGradient.ignoresSafeArea()

            switch authState {
            case .loading:
                SyncLoadingView()
                    .transition(.opacity)
            case .unauthenticated:
                LoginView(
                    onLoginSuccess: { isVip, key, expiry, type in
                        saveCredentials(key: key, type: type.rawValue, expiresAt: expiry)
                        ToastManager.shared.show("Kích hoạt bản quyền thành công!", type: .success)
                        isVipUser = isVip
                        keyType = type
                        licenseKey = key
                        expiresAt = expiry
                        authState = .authenticated
                    },
                    notificationMessage: loginNotification
                )
                .transition(.opacity.combined(with: .scale(scale: 0.98)))
            case .authenticated:
                mainShell
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            // Toast overlay
            if toastManager.isVisible {
                VStack {
                    Spacer()
                    ToastView(text: toastManager.message, type: toastManager.toastType)
                        .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.45), value: authState == .authenticated)
        .animation(.easeInOut(duration: 0.3), value: toastManager.isVisible)
        .preferredColorScheme(.dark)
        .task { await performStartup() }
        .onChange(of: authState) { newValue in
            if newValue == .authenticated { startBackgroundMonitors() }
        }
    }

    // MARK: - Main Shell

    private var mainShell: some View {
        VStack(spacing: 0) {
            topBar

            TabView(selection: $selectedTab) {
                OptimizerView(
                    keyType: keyType,
                    activeStates: $activeStates,
                    dpiFactor: $dpiFactor,
                    recoilReduction: $recoilReduction,
                    responseMs: $responseMs
                )
                .tag(0)

                UserView(
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
                        authState = .unauthenticated
                    }
                )
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(CyberTheme.bgGradient.ignoresSafeArea())
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SENSI ULTRALOCK")
                        .font(.system(.subheadline, design: .rounded).weight(.heavy))
                        .foregroundColor(CyberTheme.textPrimary)
                        .customTracking(2)
                    Text(keyType == .vip ? "VIP EDITION" : (keyType == .pro ? "PRO EDITION" : "BASIC EDITION"))
                        .font(CyberTheme.monoFontSmall)
                        .foregroundColor(keyType == .vip ? CyberTheme.cyberGold : (keyType == .pro ? CyberTheme.cyberPurple : CyberTheme.cyberCyan))
                        .customTracking(2)
                }
                Spacer()

                ZStack {
                    Circle()
                        .fill(keyType == .vip ? CyberTheme.cyberPurple : CyberTheme.darkBorder)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Circle().stroke(keyType == .vip ? CyberTheme.cyberGold : CyberTheme.textSecondary, lineWidth: 1.2)
                        )
                    Text(keyType == .vip ? "👑" : "👤")
                        .font(.system(size: 18))
                }
                .cyberGlow(keyType == .vip ? CyberTheme.cyberPurple : .clear, radius: 6, opacity: 0.5)
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 10)

            CyberSegmentedControl(
                items: [("TỐI ƯU", "slider.horizontal.3"), ("THÀNH VIÊN", "person.crop.circle")],
                selection: $selectedTab
            )
            .padding(.horizontal, 18)
            .padding(.bottom, 8)
        }
        .background(CyberTheme.cyberCardBg.opacity(0.85).ignoresSafeArea(edges: .top))
    }

    // MARK: - Startup Logic

    private func performStartup() async {
        let connected = await checkServerConnection()
        await MainActor.run { serverConnected = connected }

        let saved = loadSavedCredentials()

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
                loadFeatureStates()
                startHealthPolling()
                return
            } else {
                clearSavedCredentials()
                await MainActor.run {
                    loginNotification = "Key đã hết hạn hoặc bị thu hồi."
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

    // MARK: - Feature Persistence

    private func loadFeatureStates() {
        let saved = loadActiveFeatures()
        if !saved.isEmpty {
            activeStates = saved
        }
        dpiFactor = UserDefaults.standard.object(forKey: "tuner_dpi") as? Double ?? 1.0
        recoilReduction = UserDefaults.standard.object(forKey: "tuner_recoil") as? Double ?? 20.0
        responseMs = UserDefaults.standard.object(forKey: "tuner_response") as? Int ?? 1
    }
}
