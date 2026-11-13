//
//  Theme.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import UIKit
import ObjectiveC

// MARK: - Colours
extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }

    /// One value for light mode, another for dark mode.
    static func dynamic(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }

    // Screens and surfaces
    static let valeBackground = dynamic(light: 0xF7F8F4, dark: 0x0F1613)
    static let valeSurface    = dynamic(light: 0xFFFFFF, dark: 0x19231E)
    static let valeSoftGreen  = dynamic(light: 0xEAF1E5, dark: 0x22332A)
    static let valeBorder     = dynamic(light: 0xE1E6DD, dark: 0x2D3B34)

    // Text
    static let valeInk        = dynamic(light: 0x142820, dark: 0xEEF3EA)
    static let valeMuted      = dynamic(light: 0x6B7A72, dark: 0x9DABA3)   

    // Brand fills: stay dark green in both modes
    static let valeInkFill    = dynamic(light: 0x142820, dark: 0x1E3B2C)   
    static let valeCardEdge   = dynamic(light: 0x142820, dark: 0x35574A)
    static let valeCardMuted  = UIColor(hex: 0xA9BBB0)

    // Accents
    static let valeLime       = UIColor(hex: 0xBDF487)
    static let valeOnLime     = UIColor(hex: 0x142820)
    static let valeGreen      = dynamic(light: 0x3F7A50, dark: 0x7CC491)
    static let valeRed        = dynamic(light: 0xC0392B, dark: 0xFF6F61)
}

// MARK: - Fonts
extension UIFont {
    static func vale(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}

// MARK: - Card styles
extension UIView {
    /// Rounded card with a thin border.
    func applyCardStyle(color: UIColor = .valeSurface, radius: CGFloat = AppLayout.cornerRadius,
                        border: Bool = true, borderColor: UIColor = .valeBorder) {
        backgroundColor = color
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.borderWidth = border ? 1 : 0
        setBorderColor(borderColor)
    }

    func setBorderColor(_ color: UIColor) {
        layer.borderColor = color.resolvedColor(with: traitCollection).cgColor

        if let previous = objc_getAssociatedObject(self, &BorderKey.registration) as? any UITraitChangeRegistration {
            unregisterForTraitChanges(previous)
        }
        let registration = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: UIView, _: UITraitCollection) in
            view.layer.borderColor = color.resolvedColor(with: view.traitCollection).cgColor
        }
        objc_setAssociatedObject(self, &BorderKey.registration, registration, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private enum BorderKey {
    static var registration: UInt8 = 0
}

