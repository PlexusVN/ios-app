//
//  AppViewModel.swift
//  SensiUltralock
//
//  Global app state: auth, persistence, optimizer toggles, tuner values, toasts.
//

import SwiftUI
import Combine
import Security
import CryptoKit
import Network

// MARK: - Keychain Manager

struct KeychainManager {
    static let service = "com.aistudio.ultralock-optimizer.ios"

    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - AppViewModel

@MainActor
final class AppViewModel: ObservableObject {

    // MARK: - Auth State
    @Published var keyInput: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var isVerifying: Bool = false
    @Published var isRestoring: Bool = false
    @Published var restoreProgress: Double = 0
    @Published var authError: String?
    @Published var authResult: AuthResult?
    @Published var serverConnected: Bool = true

    // MARK: - Toast
    @Published var toast: String?
    @Published var toastType: ToastType = .info

    enum ToastType { case success, warning, info }

    // MARK: - Optimizer Toggles
    @Published var activeStates: Set<String> = []

    // MARK: - Tuner
    @Published var dpiFactor: Double = 1.0
    @Published var recoilReduction: Double = 20.0
    @Published var responseMs: Int = 1

    // MARK: - Init
    init() {
        // Restore persisted tuner values
        dpiFactor = UserDefaults.standard.object(forKey: "tuner_dpi") as? Double ?? 1.0
        recoilReduction = UserDefaults.standard.object(forKey: "tuner_recoil") as? Double ?? 20.0
        responseMs = UserDefaults.standard.object(forKey: "tuner_response") as? Int ?? 1
        // Restore feature states
        let saved = loadActiveFeatures()
        if !saved.isEmpty { activeStates = saved }
    }

    // MARK: - HWID

    private var _hwid: String?
    var hwid: String {
        if let cached = _hwid { return cached }
        let raw = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let hashed = SHA256.hash(data: Data(raw.utf8))
        let hex = hashed.map { String(format: "%02x", $0) }.prefix(8).joined()
        _hwid = hex
        return hex
    }

    // MARK: - Feature Catalog

    let allFeatures: [ModFeature] = [
        ModFeature(id: "SENSITIVITY", name: "SENSIVITY BOOSTER", description: "Nhạy Màn Hình Tối Đa"),
        ModFeature(id: "SCREEN", name: "SCREEN BOOSTER", description: "Buff FPS Siêu Mượt"),
        ModFeature(id: "BUFF_120HZ", name: "BUFF 120HZ SCREEN", description: "Tần Số Quét 120Hz"),
        ModFeature(id: "FEATHER", name: "FEATHER AIM", description: "Nhẹ Tâm Nhắm FF"),
        ModFeature(id: "HEADSHOT", name: "HEADSHOT FIX", description: "Fix Lỗi Nhắm Headshot"),
        ModFeature(id: "AIMLOCK_PRO", name: "AIMLOCK ASSIST PRO", description: "Hỗ Trợ Khóa Tâm Chuyên Nghiệp"),
        ModFeature(id: "AUTO_TRIGGER", name: "AUTO TRIGGER PRO", description: "Tự Động Bắn Siêu Tốc"),
        ModFeature(id: "RECOIL_REDUCTION", name: "RECOIL CONTROL PRO", description: "Ghìn Tâm Giảm Giật Tối Đa"),
        ModFeature(id: "AIMLOCK", name: "AIMLOCK ULTRA", description: "Khóa Tâm Bám Đầu [VIP]", isVipOnly: true),
        ModFeature(id: "ANCHOR", name: "ANCHOR AIM", description: "Ghìn Tâm Tự Động [VIP]", isVipOnly: true)
    ]

    var basicFeatures: [ModFeature] { Array(allFeatures.prefix(5)) }
    var proFeatures: [ModFeature] { Array(allFeatures[5..<8]) }
    var vipFeatures: [ModFeature] { Array(allFeatures.suffix(2)) }

    var activeCount: Int { activeStates.count }
    var totalCount: Int { allFeatures.count }
    var optimizationPercent: Double {
        guard totalCount > 0 else { return 0 }
        return Double(activeCount) / Double(totalCount) * 100
    }

    // MARK: - Auth Computed

    var currentTier: KeyType {
        guard let result = authResult else { return .basic }
        return computeKeyType(from: result.type)
    }

    var isVIP: Bool { currentTier == .vip }
    var isProOrHigher: Bool { currentTier == .pro || currentTier == .vip }

    // MARK: - Restore Session

    func restoreSessionIfNeeded() async {
        // Try Keychain first, then UserDefaults
        let savedKey: String? = KeychainManager.read(key: "saved_license_key")
            ?? UserDefaults.standard.string(forKey: "plexus_license_key")

        guard let key = savedKey, !key.isEmpty, !isAuthenticated, !isRestoring else { return }

        isRestoring = true
        restoreProgress = 0
        keyInput = key

        // Animate progress
        async let _: Void = animateProgress(to: 0.9, over: 1.2)

        // Check server health
        serverConnected = await checkServerConnection()

        await verifyKey(silent: true)

        restoreProgress = 1.0
        try? await Task.sleep(for: .seconds(0.25))
        isRestoring = false
    }

    private func animateProgress(to target: Double, over duration: Double) async {
        let steps = 30
        let stepDuration = duration / Double(steps)
        for i in 1...steps {
            try? await Task.sleep(for: .seconds(stepDuration))
            restoreProgress = min(target, Double(i) / Double(steps) * target)
        }
    }

    // MARK: - Auth

    func verifyKey(silent: Bool = false) async {
        let trimmed = keyInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            if !silent { authError = "Vui lòng nhập License Key." }
            Haptics.error()
            return
        }
        if !silent { isVerifying = true }
        authError = nil
        defer { if !silent { isVerifying = false } }

        let secret = "ios-auth-key"
        guard let encodedKey = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedHWID = hwid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://plexus-auth-api-o01h.onrender.com/api/verify?key=\(encodedKey)&hwid=\(encodedHWID)&secret=\(encodedSecret)") else {
            if !silent { authError = "Địa chỉ API không hợp lệ." }
            Haptics.error()
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                if !silent { authError = "Máy chủ trả về lỗi (\(http.statusCode))." }
                Haptics.error()
                return
            }
            let decoded = try JSONDecoder().decode(AuthResult.self, from: data)
            authResult = decoded
            if decoded.success && decoded.status == "valid" {
                isAuthenticated = true
                saveCredentials(key: trimmed, type: decoded.type, expiresAt: decoded.expiresAt)
                startMonitor()
                if !silent { showToast("✅ Kích hoạt thành công!", type: .success) }
                Haptics.success()
            } else {
                if !silent { authError = decoded.message.isEmpty ? "Key không hợp lệ hoặc đã hết hạn." : decoded.message }
                Haptics.error()
            }
        } catch {
            if !silent { authError = "Không thể kết nối máy chủ. Thử lại sau." }
            Haptics.error()
        }
    }

    func logout() {
        Haptics.medium()
        stopMonitor()
        clearSession()
        showToast("Đã đăng xuất hệ thống Plexus.", type: .warning)
    }

    private func clearSession() {
        clearSavedCredentials()
        UserDefaults.standard.removeObject(forKey: "plexus_license_key")
        keyInput = ""
        authResult = nil
        isAuthenticated = false
        activeStates.removeAll()
        dpiFactor = 1.0
        recoilReduction = 20.0
        responseMs = 1
    }

    // MARK: - Credentials Persistence

    private let CRED_KEY_KEY = "saved_license_key"
    private let CRED_TYPE_KEY = "saved_key_type"
    private let CRED_EXPIRY_KEY = "saved_expires_at"

    private func saveCredentials(key: String, type: String, expiresAt: String) {
        KeychainManager.save(key: CRED_KEY_KEY, value: key)
        UserDefaults.standard.set(type, forKey: CRED_TYPE_KEY)
        UserDefaults.standard.set(expiresAt, forKey: CRED_EXPIRY_KEY)
    }

    private func clearSavedCredentials() {
        KeychainManager.delete(key: CRED_KEY_KEY)
        UserDefaults.standard.removeObject(forKey: CRED_TYPE_KEY)
        UserDefaults.standard.removeObject(forKey: CRED_EXPIRY_KEY)
    }

    func savedLicenseKey() -> String? {
        KeychainManager.read(key: CRED_KEY_KEY)
    }

    func savedExpiresAt() -> String {
        UserDefaults.standard.string(forKey: CRED_EXPIRY_KEY) ?? ""
    }

    // MARK: - Server Health

    func checkServerConnection() async -> Bool {
        guard let url = URL(string: "https://plexus-auth-api-o01h.onrender.com/api/health") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch { return false }
    }

    // MARK: - Background Monitor

    private var monitorTask: Task<Void, Never>?

    func startMonitor() {
        stopMonitor()
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                guard let self, !Task.isCancelled else { return }
                await self.reverifySilent()
            }
        }
    }

    func stopMonitor() {
        monitorTask?.cancel()
        monitorTask = nil
    }

    private func reverifySilent() async {
        guard isAuthenticated,
              let savedKey = savedLicenseKey(),
              !savedKey.isEmpty else { return }
        let secret = "ios-auth-key"
        guard let encodedKey = savedKey.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedHWID = hwid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://plexus-auth-api-o01h.onrender.com/api/verify?key=\(encodedKey)&hwid=\(encodedHWID)&secret=\(encodedSecret)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(AuthResult.self, from: data)
            authResult = decoded
            if !decoded.success || decoded.status != "valid" {
                Haptics.error()
                showToast("⚠️ Phiên đăng nhập đã bị thu hồi trên máy chủ.", type: .warning)
                clearSession()
            } else {
                UserDefaults.standard.set(decoded.type, forKey: CRED_TYPE_KEY)
                UserDefaults.standard.set(decoded.expiresAt, forKey: CRED_EXPIRY_KEY)
            }
        } catch {
            // Network blip — don't log out
        }
    }

    // MARK: - Toast

    func showToast(_ text: String, type: ToastType = .info) {
        toastType = type
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { toast = text }
        Task {
            try? await Task.sleep(for: .seconds(2.5))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.3)) { toast = nil }
            }
        }
    }

    // MARK: - Feature Persistence

    private let ACTIVE_FEATURES_KEY = "active_features"

    func saveActiveFeatures() {
        UserDefaults.standard.set(Array(activeStates), forKey: ACTIVE_FEATURES_KEY)
    }

    func loadActiveFeatures() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: ACTIVE_FEATURES_KEY) ?? [])
    }

    func toggleFeature(_ feature: ModFeature) {
        if feature.isVipOnly && !isVIP {
            Haptics.error()
            showToast("🔒 Tính năng này chỉ dành cho VIP!", type: .warning)
            return
        }
        Haptics.medium()
        if activeStates.contains(feature.id) {
            activeStates.remove(feature.id)
            showToast("Đã tắt: \(feature.name)", type: .info)
        } else {
            activeStates.insert(feature.id)
            showToast("Đã bật: \(feature.name)", type: .success)
        }
        saveActiveFeatures()
    }

    func isFeatureOn(_ feature: ModFeature) -> Bool {
        activeStates.contains(feature.id)
    }

    // MARK: - Tuner Persistence

    func saveTunerDPI() {
        UserDefaults.standard.set(dpiFactor, forKey: "tuner_dpi")
    }

    func saveTunerRecoil() {
        UserDefaults.standard.set(recoilReduction, forKey: "tuner_recoil")
    }

    func saveTunerResponse() {
        UserDefaults.standard.set(responseMs, forKey: "tuner_response")
    }
}

// MARK: - Compute Key Type

func computeKeyType(from typeString: String) -> KeyType {
    let t = typeString.lowercased().trimmingCharacters(in: .whitespaces)
    if t.contains("vip") || t.contains("admin") { return .vip }
    if t.contains("pro") { return .pro }
    return .basic
}
