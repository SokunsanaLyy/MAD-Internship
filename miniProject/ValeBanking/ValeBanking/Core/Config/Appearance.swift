//
//  Appearance.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 13/11/2026.
//

import UIKit

// MARK: - Appearance

enum Appearance: Int, CaseIterable {
    case system
    case light
    case dark

    private static let key = "settings.appearance"

    static var current: Appearance {
        Appearance(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .system
    }

    static func select(_ appearance: Appearance) {
        UserDefaults.standard.set(appearance.rawValue, forKey: key)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach(appearance.apply)
    }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var style: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }

    func apply(to window: UIWindow) {
        window.overrideUserInterfaceStyle = style
    }
}
