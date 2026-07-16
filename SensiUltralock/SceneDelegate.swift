import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        // Force the window to fill the entire physical screen — kills letterbox
        window.frame = windowScene.screen.bounds
        window.rootViewController = UIHostingController(
            rootView: ContentView().preferredColorScheme(.dark)
        )
        window.makeKeyAndVisible()
        self.window = window
    }
}
