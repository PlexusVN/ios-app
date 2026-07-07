import Foundation

// MARK: - Auth Models

struct AuthResult: Codable {
    let success: Bool
    let status: String
    let message: String
    let expiresAt: String
    let serverTime: String
    let type: String

    enum CodingKeys: String, CodingKey {
        case success, status, message
        case expiresAt = "expires_at"
        case serverTime = "server_time"
        case type
    }
}

enum AuthState {
    case loading
    case unauthenticated
    case authenticated
}

enum KeyType: String {
    case basic = "basic"
    case pro = "pro"
    case vip = "vip"
}

// MARK: - ModFeature Model

struct ModFeature: Identifiable {
    let id: String
    let name: String
    let description: String
    let defaultActive: Bool
    let isVipOnly: Bool

    init(id: String, name: String, description: String,
         defaultActive: Bool = false, isVipOnly: Bool = false) {
        self.id = id
        self.name = name
        self.description = description
        self.defaultActive = defaultActive
        self.isVipOnly = isVipOnly
    }
}
