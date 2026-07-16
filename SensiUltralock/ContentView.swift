import SwiftUI

struct ContentView: View {
    @State private var authState: AuthState = .loading
    @State private var isVipUser = false
    @State private var keyType: KeyType = .basic
    @State private var licenseKey = ""
    @State private var expiresAt = ""

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let scale = min(max(w / 375, 0.75), 1.5)
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            let dim = ViewDimensions(w: w, h: h, scale: scale, safeTop: safeTop, safeBottom: safeBottom)

            ZStack {
                CyberBg.ignoresSafeArea()

                switch authState {
                case .loading:
                    LoadingView(dim: dim)
                case .unauthenticated:
                    LoginView(dim: dim) { isVip, key, expiry, type in
                        isVipUser = isVip
                        keyType = type
                        licenseKey = key
                        expiresAt = expiry
                        authState = .authenticated
                    }
                case .authenticated:
                    DashboardView(
                        dim: dim,
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
        }
        .preferredColorScheme(.dark)
        .onAppear {
            authState = .unauthenticated
        }
        .onChange(of: authState) { newValue in
            if newValue == .authenticated {
                startBackgroundMonitor()
            }
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
                    await MainActor.run {
                        authState = .unauthenticated
                    }
                }
            }
        }
    }
}
