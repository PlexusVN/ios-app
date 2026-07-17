import SwiftUI
import UIKit

/// Ensure UIWindow covers the entire screen with no letterbox effect
/// Call this in SceneDelegate or SwiftUI app if needed for full-screen guarantee
final class WindowConfigurator {
    static func configureWindow(_ window: UIWindow) {
        // Set frame to full screen without constraints
        if let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let bounds = screen.screen.bounds
            window.frame = bounds
            window.windowScene = screen
            
            // Ensure view controller is resizing properly
            window.rootViewController?.view.frame = bounds
            window.rootViewController?.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
}
