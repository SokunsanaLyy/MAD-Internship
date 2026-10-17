//
//  MenuOption.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - MenuOption
// One row on the Transfers menu (Screen 1).
struct MenuOption {
    let icon: String
    let tint: UIColor
    let title: String
    let subtitle: String
    let hasSubmenu: Bool
}

// MARK: - Menu rows
// Kept here, not in the ViewController, so the controller only handles the screen.
extension MenuOption {
    static let ownAccountsTitle = "Own Accounts"

    static let transferOptions: [MenuOption] = [
        MenuOption(icon: "arrow.left.arrow.right", tint: .brandIndigo, title: ownAccountsTitle,
                   subtitle: "Own account transfers", hasSubmenu: false),
        MenuOption(icon: "person.2.fill", tint: .brandNavy, title: "Bank Accounts | Phone",
                   subtitle: "Transfer to bank accounts | phone numbers", hasSubmenu: false),
        MenuOption(icon: "building.columns.fill", tint: .systemPurple, title: "Local Transfers",
                   subtitle: "Transfer to banks | MFIs | wallets", hasSubmenu: true),
        MenuOption(icon: "globe.asia.australia.fill", tint: .systemTeal, title: "International Transfers",
                   subtitle: "Transfer worldwide to banks | agents", hasSubmenu: true),
        MenuOption(icon: "creditcard.fill", tint: .systemPink, title: "Card Transfers",
                   subtitle: "Transfer to other bank cards", hasSubmenu: true)
    ]
}

