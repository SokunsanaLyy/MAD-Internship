//
//  MainTabBarController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 2/11/2026.
//

import UIKit

// MARK: - MainTabBarController

final class MainTabBarController: UITabBarController {

    enum Tab: Int {
        case home, cards, dashboard, profile
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
        Task { await AppStore.shared.loadAll() }
    }

    private func setupTabs() {
        viewControllers = [
            makeTab(HomeViewController(), title: "Home", symbol: "house"),
            makeTab(CardViewController(), title: "Cards", symbol: "creditcard"),
            makeTab(DashboardViewController(), title: "Dashboard", symbol: "chart.bar"),
            makeTab(ProfileViewController(), title: "Profile", symbol: "person")
        ]
    }

    private func makeTab(_ root: UIViewController, title: String, symbol: String) -> UIViewController {
        let navigation = UINavigationController(rootViewController: root)
        navigation.setNavigationBarHidden(true, animated: false)     // each screen draws its own header
        navigation.tabBarItem = UITabBarItem(title: title,
                                             image: UIImage(systemName: symbol),
                                             selectedImage: UIImage(systemName: symbol + ".fill"))
        return navigation
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = .valeInk
        tabBar.unselectedItemTintColor = .valeMuted
    }

    func select(_ tab: Tab) {
        selectedIndex = tab.rawValue
    }
}
