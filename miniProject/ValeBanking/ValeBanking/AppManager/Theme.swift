//
//  Theme.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import UIKit

// MARK: - Colours (from the Vale Figma file)
extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }

    static let valeBackground = UIColor(hex: 0xF7F8F4)   // screen background
    static let valeInk        = UIColor(hex: 0x142820)   // titles, dark card, primary button
    static let valeLime       = UIColor(hex: 0xBDF487)   // highlight (Pay, selected tile, chart)
    static let valeGreen      = UIColor(hex: 0x3F7A50)   // links, "Active", income
    static let valeSoftGreen  = UIColor(hex: 0xEAF1E5)   // icon tiles, spent card
    static let valeMuted      = UIColor(hex: 0x6B7A72)   // secondary text
    static let valeBorder     = UIColor(hex: 0xE1E6DD)   // field and card borders
    static let valeRed        = UIColor(hex: 0xC0392B)   // errors, log out
    static let valeCardMuted  = UIColor(hex: 0xA9BBB0)   // secondary text on the dark card
}

// MARK: - Fonts
extension UIFont {
    static func vale(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}

// MARK: - Card styles
extension UIView {
    /// White rounded card with a thin border.
    func applyCardStyle(color: UIColor = .white, radius: CGFloat = AppLayout.cornerRadius, border: Bool = true) {
        backgroundColor = color
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.borderWidth = border ? 1 : 0
        layer.borderColor = UIColor.valeBorder.cgColor
    }
}
