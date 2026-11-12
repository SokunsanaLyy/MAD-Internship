//
//  TransactionCell.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

// MARK: - TransactionCell

final class TransactionCell: UITableViewCell {

    static let reuseID = "TransactionCell"

    private let icon = IconTileView(symbol: "dollarsign.circle", size: 42, background: .white)
    private let titleLabel = UILabel(font: .vale(16, .semibold))
    private let detailLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let amountLabel = UILabel(font: .vale(16, .semibold))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with transaction: Transaction) {
        icon.setSymbol(transaction.symbol)
        titleLabel.text = transaction.title
        detailLabel.text = "\(transaction.category) · \(Format.shortDate(transaction.date))"
        amountLabel.text = Format.signedMoney(transaction.amount)
        amountLabel.textColor = transaction.isIncome ? .valeGreen : .valeInk
        accessibilityLabel = "\(transaction.title), \(detailLabel.text ?? ""), \(amountLabel.text ?? "")"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        detailLabel.text = nil
        amountLabel.text = nil
    }

    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none
        isAccessibilityElement = true
        icon.layer.borderWidth = 1
        icon.layer.borderColor = UIColor.valeBorder.cgColor

        amountLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        let texts = UIStackView(axis: .vertical, spacing: 3, views: [titleLabel, detailLabel])
        let row = UIStackView(axis: .horizontal, spacing: 14, alignment: .center, views: [icon, texts, .spacer(), amountLabel])
        contentView.addSubviews(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: 10, left: AppLayout.screenPadding,
                                                            bottom: 10, right: AppLayout.screenPadding))
    }
}
