import Foundation
import UIKit
import Security
import CommonCrypto

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

// MARK: - HWID Generator

func getHWID() -> String {
    let identifier = UIDevice.current.identifierForVendor?.uuidString ?? "UNKNOWN_IOS"
    guard let data = identifier.data(using: .utf8) else {
        return "UNKNOWN-" + UUID().uuidString.prefix(8)
    }
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { buffer in
        _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
    }
    let hex = hash.prefix(8).map { String(format: "%02x", $0) }.joined()
    return hex
}

// MARK: - Plexus Auth API

func verifyLicenseKey(key: String) async -> AuthResult? {
    let hwid = getHWID()
    guard let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let encodedHWID = hwid.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: "https://plexus-auth-api.onrender.com/api/verify?key=\(encodedKey)&hwid=\(encodedHWID)") else {
        return nil
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 10

    do {
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let result = try decoder.decode(AuthResult.self, from: data)
        return result
    } catch {
        return AuthResult(
            success: false,
            status: "error",
            message: "Kết nối máy chủ Plexus thất bại: \(error.localizedDescription)",
            expiresAt: "",
            serverTime: "",
            type: ""
        )
    }
}

func computeKeyType(from typeString: String) -> KeyType {
    let t = typeString.lowercased().trimmingCharacters(in: .whitespaces)
    if t.contains("vip") || t.contains("admin") { return .vip }
    if t.contains("pro") { return .pro }
    return .basic
}
