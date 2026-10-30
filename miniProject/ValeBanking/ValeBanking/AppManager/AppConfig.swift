//
//  AppConfig.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import UIKit

// MARK: - AppConfig
// Settings used across the app. Change them here, not inside screens.
enum AppConfig {
    /// Mockoon "Vale API" environment. The Simulator reaches your Mac through localhost.
    static let apiBaseURL = URL(string: "http://localhost:3002")!
    static let requestTimeout: TimeInterval = 15
    static let otpLength = 6
    static let resendSeconds = 30
}

// MARK: - AppLayout
enum AppLayout {
    static let screenPadding: CGFloat = 20
    static let cornerRadius: CGFloat = 16
    static let buttonHeight: CGFloat = 52
    static let fieldHeight: CGFloat = 52
    static let itemSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 28
}

// MARK: - KeychainKey
// Names of the items saved in the Keychain.
enum KeychainKey {
    static let accessToken = "vale.accessToken"
}
