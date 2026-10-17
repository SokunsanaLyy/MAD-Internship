//
//  AccountCell.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - Account cell
final class AccountCell: UITableViewCell {

    static let reuseID = "AccountCell"

    private let numberLabel = UILabel.make(size: 15, weight: .medium, color: .brandNavy)
    private let currencyLabel = UILabel.make(size: 12, weight: .bold)
    private let typeLabel = UILabel.make(size: 12, color: .secondaryLabel)
    private let balanceLabel = UILabel.make(size: 15, weight: .semibold)
    private let checkView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        checkView.tintColor = .gold
        currencyLabel.textAlignment = .right
        balanceLabel.textAlignment = .right

        let topRow = UIStackView(arrangedSubviews: [numberLabel, currencyLabel])
        let bottomRow = UIStackView(arrangedSubviews: [typeLabel, balanceLabel])
        [topRow, bottomRow].forEach { $0.axis = .horizontal; $0.distribution = .fill }
        numberLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        typeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [topRow, bottomRow])
        textStack.axis = .vertical
        textStack.spacing = 6

        let row = UIStackView(arrangedSubviews: [textStack, checkView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        contentView.addSubview(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with account: Account, isSelected: Bool) {
        numberLabel.text = account.number
        currencyLabel.text = account.currency
        currencyLabel.textColor = account.currencyColor
        typeLabel.text = account.type
        balanceLabel.text = account.formattedBalance
        balanceLabel.textColor = account.currencyColor
        checkView.isHidden = !isSelected
        backgroundColor = isSelected ? UIColor.brandNavy.withAlphaComponent(0.06) : .clear
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}


