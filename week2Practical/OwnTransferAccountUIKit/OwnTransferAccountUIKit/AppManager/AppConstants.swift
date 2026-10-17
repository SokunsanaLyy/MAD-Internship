import UIKit

// MARK: - AppLayout
// Spacing and sizes shared by several screens.
// Change a value here and every screen that uses it updates.
enum AppLayout {
    static let screenPadding: CGFloat = 20        // left/right margin of screen content
    static let sheetCornerRadius: CGFloat = 24    // rounded top of the white/grey sheets
    static let bottomButtonInset: CGFloat = 12    // gap between a bottom button and the safe area
    static let animationDuration: TimeInterval = 0.25
}

// MARK: - AppText
// Text used on more than one screen.
enum AppText {
    static let transfersTitle = "Transfers"
    static let bankName = "My Bank"               // placeholder for the bank's logo
}
