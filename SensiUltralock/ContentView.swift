import SwiftUI

struct ContentView: View {
    @State private var authState: AuthState = .loading
    @State private var isVipUser = false
    @State private var keyType: KeyType = .basic
    @State private var licenseKey = ""
    @State private var expiresAt = ""

    var body: some View {
        ZStack {
            CyberBg.ignoresSafeArea()

            switch authState {
            case .loading:
                LoadingView()
            case .unauthenticated:
                LoginView { isVip, key, expiry, type in
                    isVipUser = isVip
                    keyType = type
                    licenseKey = key
                    expiresAt = expiry
                    authState = .authenticated
                }
            case .authenticated:
                DashboardView(
                    isVip: isVipUser,
                    keyType: keyType,
                    licenseKey: licenseKey,
                    expiresAt: expiresAt,
                    onLogout: {
                        licenseKey = ""
                        expiresAt = ""
                        isVipUser = false
                        keyType = .basic
                        authState = .unauthenticated
                    }
                )
            }
        }
        .task {
            await autoLogin()
            startBackgroundMonitor()
        }
    }

    // MARK: - Auto-login on launch

    private func autoLogin() async {
        let savedKey = KeychainManager.read(key: "saved_key") ?? ""
        if savedKey.isEmpty {
            authState = .unauthenticated
            return
        }
        let result = await verifyLicenseKey(key: savedKey)
        if let r = result, r.success, r.status == "valid" {
            let computedType = computeKeyType(from: r.type)
            isVipUser = computedType == .vip
            keyType = computedType
            licenseKey = savedKey
            expiresAt = r.expiresAt
            authState = .authenticated
        } else {
            KeychainManager.delete(key: "saved_key")
            authState = .unauthenticated
        }
    }

    // MARK: - Background Monitor (re-verify every 60s)

    private func startBackgroundMonitor() {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 60_000_000_000)
                guard authState == .authenticated else { break }
                let result = await verifyLicenseKey(key: licenseKey)
                if result == nil || !result!.success || result!.status != "valid" {
                    KeychainManager.delete(key: "saved_key")
                    await MainActor.run {
                        authState = .unauthenticated
                    }
                }
            }
        }
    }
}
