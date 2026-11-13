//
//  ValeButton.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

// MARK: - ValeButton

final class ValeButton: UIButton {

    enum Style {
        case primary, outline, lime, white, tile
    }

    private let style: Style

    init(_ title: String, symbol: String? = nil, style: Style = .primary, trailingIcon: Bool = false) {
        self.style = style
        super.init(frame: .zero)

        let isQuickAction = style == .lime || style == .white     // Pay, Transfer, Details

        var config: UIButton.Configuration = style == .primary ? .filled() : .plain()
        config.title = title
        config.imagePadding = style == .tile ? 10 : (isQuickAction ? 6 : 8)
        config.imagePlacement = style == .tile ? .top : (trailingIcon ? .trailing : .leading)
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
            pointSize: style == .tile ? 18 : (isQuickAction ? 12 : 14),
            weight: .semibold)
        if let symbol { config.image = UIImage(systemName: symbol) }

        // Quick actions share a row of three, so keep their side padding small
        if isQuickAction {
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        }
        config.titleLineBreakMode = .byTruncatingTail

        config.background.cornerRadius = 14
        config.cornerStyle = .fixed
        let font = UIFont.vale(style == .tile ? 13 : (isQuickAction ? 14 : 16), .semibold)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        configuration = config
        applyColors()

        let height: CGFloat = style == .tile ? 88 : (style == .lime || style == .white ? 44 : AppLayout.buttonHeight)
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Shows a spinner and blocks taps while a request is running.
    var isLoading = false {
        didSet {
            configuration?.showsActivityIndicator = isLoading
            isEnabled = !isLoading
        }
    }

    /// Lets a tile switch between lime (on) and white (off), e.g. Lock card.
    var isHighlightedTile = false {
        didSet { applyColors() }
    }

    func setLabel(_ title: String, symbol: String? = nil) {
        configuration?.title = title
        if let symbol { configuration?.image = UIImage(systemName: symbol) }
    }

    private func applyColors() {
        guard var config = configuration else { return }
        switch style {
        case .primary:
            config.baseBackgroundColor = .valeInkFill
            config.baseForegroundColor = .white
            config.background.strokeColor = .valeCardEdge
            config.background.strokeWidth = 1
        case .outline:
            config.baseForegroundColor = .valeInk
            config.background.backgroundColor = .valeSurface
            config.background.strokeColor = .valeBorder
            config.background.strokeWidth = 1
        case .lime:
            config.baseForegroundColor = .valeOnLime
            config.background.backgroundColor = .valeLime
        case .white:
            config.baseForegroundColor = .valeInk
            config.background.backgroundColor = .valeSurface
        case .tile:
            config.baseForegroundColor = isHighlightedTile ? .valeOnLime : .valeInk
            config.background.backgroundColor = isHighlightedTile ? .valeLime : .valeSurface
        }
        configuration = config
    }
}

// MARK: - TextButton

func makeTextButton(_ title: String, size: CGFloat = 14) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.title = title
    config.baseForegroundColor = .valeGreen
    config.contentInsets = .zero
    let font = UIFont.vale(size, .semibold)
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.font = font
        return outgoing
    }
    return UIButton(configuration: config)
}

// MARK: - CircleIconButton

func makeCircleButton(symbol: String, size: CGFloat = 44) -> UIButton {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: symbol)
    config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
    config.baseForegroundColor = .valeInk
    config.background.backgroundColor = .valeSurface
    config.background.strokeColor = .valeBorder
    config.background.strokeWidth = 1
    config.cornerStyle = .capsule
    let button = UIButton(configuration: config)
    button.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: size),
        button.heightAnchor.constraint(equalToConstant: size)
    ])
    return button
}
