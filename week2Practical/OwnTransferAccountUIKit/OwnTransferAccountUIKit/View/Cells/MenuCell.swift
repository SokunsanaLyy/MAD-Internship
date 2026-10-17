//
//  MenuCell.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - Menu cell
final class MenuCell: UITableViewCell {

    static let reuseID = "MenuCell"

    private let card = UIView()
    private let iconTile = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel.make(size: 15, weight: .semibold, color: .brandNavy)
    private let subtitleLabel = UILabel.make(size: 12, color: .secondaryLabel, lines: 0)
    private let arrowView = UIImageView(image: UIImage(systemName: "arrowtriangle.right.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none                 // we show our own press effect

        card.applyCardStyle()
        iconTile.layer.cornerRadius = 9
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        arrowView.tintColor = .gold
        arrowView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10)

        let divider = UIView()
        divider.backgroundColor = .fieldBorder

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [iconTile, divider, textStack, arrowView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        iconTile.addSubviews(iconView)
        contentView.addSubview(card)
        card.addSubview(row)
        card.pinEdges(to: contentView, insets: UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16))
        row.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        [iconTile, divider].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        NSLayoutConstraint.activate([
            iconTile.widthAnchor.constraint(equalToConstant: 34),
            iconTile.heightAnchor.constraint(equalToConstant: 34),
            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with option: MenuOption) {
        iconTile.backgroundColor = option.tint
        iconView.image = UIImage(systemName: option.icon)
        titleLabel.text = option.title
        subtitleLabel.text = option.subtitle
        arrowView.isHidden = !option.hasSubmenu
    }

    // The card dims while a finger is on it.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) { self.card.alpha = highlighted ? 0.6 : 1 }
    }
}

