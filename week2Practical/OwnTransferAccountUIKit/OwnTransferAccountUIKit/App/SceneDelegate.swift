import UIKit

// MARK: - SceneDelegate
// Creates the window and the first screen.
//
//   UIWindow
//    └─ AppNavigationController  (keeps the back stack: push = forward, pop = back)
//        └─ TransferMenuViewController  (Screen 1)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // ONE shared store for the whole transfer flow (same role as the Android ViewModel).
    // It is created once here and handed to each screen.
    private let store = TransferStore()

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let menu = TransferMenuViewController(store: store)
        window.rootViewController = AppNavigationController(rootViewController: menu)
        window.makeKeyAndVisible()
        self.window = window
    }
}

// MARK: - AppNavigationController
// A UINavigationController with the system bar hidden (every screen draws its own header),
// but with the iOS "swipe from the left edge to go back" gesture still working.
final class AppNavigationController: UINavigationController, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarHidden(true, animated: false)
        // Hiding the bar normally switches off swipe-back. Becoming the gesture's delegate turns it on again.
        interactivePopGestureRecognizer?.delegate = self
    }

    // Allow swipe-back only when there is a screen to go back to.
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    // Let the visible screen choose the status bar style (white text on the blue sky).
    override var childForStatusBarStyle: UIViewController? { topViewController }
}
