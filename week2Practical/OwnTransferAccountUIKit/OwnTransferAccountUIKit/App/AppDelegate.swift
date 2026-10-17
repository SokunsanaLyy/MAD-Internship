import UIKit

// MARK: - AppDelegate
// The app's starting point. `@main` tells iOS "start the app here".
// There must be only ONE @main in the project.
//
// With scenes (iOS 13+), the AppDelegate handles app-wide events only.
// The window and the first screen are created in SceneDelegate.
@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Nothing to set up yet. Don't create a window here — SceneDelegate does that.
        return true
    }

    // Tells iOS which scene configuration (from Info.plist) to use for a new window.
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
