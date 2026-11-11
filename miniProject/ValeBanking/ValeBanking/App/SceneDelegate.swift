//
//  SceneDelegate.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var privacyCover: UIView?

    private var lockWindow: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        SessionStore.shared.onChange = { [weak self] state in
            self?.showRoot(for: state, animated: true)
            if state == .signedIn { AppLock.shared.userSignedIn() }
        }
        AppLock.shared.onChange = { [weak self] status in
            self?.updateLock(for: status)
        }

        showRoot(for: SessionStore.shared.state, animated: false)
        window.makeKeyAndVisible()

        if SessionStore.shared.state == .signedIn {
            AppLock.shared.appLaunchedSignedIn()
        }
    }

    // MARK: - Root switching

    private func showRoot(for state: SessionStore.State, animated: Bool) {
        guard let window else { return }

        switch state {
        case .signedOut:
            let navigation = UINavigationController(rootViewController: LoginViewController())
            navigation.setNavigationBarHidden(true, animated: false)
            window.rootViewController = navigation
        case .signedIn:
            window.rootViewController = MainTabBarController()
        }

        if animated {
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }

    // MARK: - App lock

    private func updateLock(for status: AppLock.Status) {
        switch status {
        case .unlocked: hideLock()
        case .locked: showLock(.unlock)
        case .needsPasscode: showLock(.create)
        }
    }

    private func showLock(_ mode: PasscodeViewModel.Mode) {
        guard let scene = window?.windowScene else { return }
        let lock = UIWindow(windowScene: scene)
        lock.windowLevel = .alert + 1
        lock.rootViewController = PasscodeViewController(mode: mode)
        lock.makeKeyAndVisible()
        lockWindow?.isHidden = true
        lockWindow = lock
    }

    private func hideLock() {
        lockWindow?.isHidden = true
        lockWindow = nil
        window?.makeKey()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AppLock.shared.appDidEnterBackground()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        AppLock.shared.appWillEnterForeground()      
    }

    // MARK: - Privacy cover (app switcher)

    func sceneWillResignActive(_ scene: UIScene) {
        guard let window, privacyCover == nil else { return }
        let cover = UIView(frame: window.bounds)
        cover.backgroundColor = .valeInk
        let logo = UIImageView(symbol: "leaf.fill", size: 44, color: .valeLime)
        cover.addSubviews(logo)
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: cover.centerXAnchor),
            logo.centerYAnchor.constraint(equalTo: cover.centerYAnchor)
        ])
        window.addSubview(cover)
        privacyCover = cover
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        privacyCover?.removeFromSuperview()
        privacyCover = nil
    }
}
