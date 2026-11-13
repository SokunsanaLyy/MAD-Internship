//
//  BalanceCardView.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

// MARK: - BalanceCardView (Home)

final class BalanceCardView: UIView {

    private let nameLabel = UILabel(font: .vale(15), color: .valeCardMuted)
    private let arrow = UIImageView(symbol: "arrow.up.right", size: 14, weight: .semibold, color: .valeLime)
    private let amountLabel = UILabel(text: "—", font: .vale(44, .medium), color: .white)
    private let captionLabel = UILabel(text: "Available balance", font: .vale(13), color: .valeCardMuted)
    private let numberLabel = UILabel(font: .vale(13, .medium), color: .valeCardMuted)
    private let lockedChip = UILabel(text: " Card locked ", font: .vale(12, .semibold), color: .valeOnLime)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(account: Account?, cardLocked: Bool) {
        nameLabel.text = account?.name ?? "Everyday checking"
        amountLabel.text = account.map { Format.money($0.balance) } ?? "—"
        numberLabel.text = account.map { Format.masked($0.last4) }
        lockedChip.isHidden = !cardLocked
        accessibilityLabel = "\(nameLabel.text ?? ""), available balance \(amountLabel.text ?? "")"
            + (cardLocked ? ", card locked" : "")
    }

    private func setupViews() {
        applyCardStyle(color: .valeInkFill, radius: 24, border: true, borderColor: .valeCardEdge)
        isAccessibilityElement = true

        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.6

        lockedChip.backgroundColor = .valeLime
        lockedChip.layer.cornerRadius = 10
        lockedChip.clipsToBounds = true
        lockedChip.isHidden = true

        let top = UIStackView(axis: .horizontal, alignment: .center, views: [nameLabel, .spacer(), arrow])
        let bottom = UIStackView(axis: .horizontal, spacing: 8, alignment: .center,
                                 views: [captionLabel, .spacer(), lockedChip, numberLabel])
        let stack = UIStackView(axis: .vertical, spacing: 10, views: [top, amountLabel, bottom])
        stack.setCustomSpacing(18, after: amountLabel)

        addSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        lockedChip.heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
}

// MARK: - SpentCardView (Home)

final class SpentCardView: UIView {

    private let titleLabel = UILabel(text: "Spent this month", font: .vale(14), color: .valeMuted)
    private let amountLabel = UILabel(text: "—", font: .vale(28, .medium))
    private let changeLabel = UILabel(font: .vale(13, .medium), color: .valeGreen)

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyCardStyle(color: .valeSoftGreen, border: false)
        let arrow = UIImageView(symbol: "arrow.up.right", size: 13, weight: .semibold, color: .valeGreen)
        let top = UIStackView(axis: .horizontal, views: [titleLabel, .spacer(), arrow])
        let bottom = UIStackView(axis: .horizontal, alignment: .lastBaseline, views: [amountLabel, .spacer(), changeLabel])
        let stack = UIStackView(axis: .vertical, spacing: 6, views: [top, bottom])
        addSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ spending: Spending?) {
        guard let spending else { return }
        let monthName = spending.month.components(separatedBy: " ").first ?? "this month"
        titleLabel.text = "Spent this \(monthName)"
        amountLabel.text = Format.money(spending.total)
        let less = spending.changePercent < 0
        changeLabel.text = "\(less ? "↘" : "↗") \(abs(spending.changePercent))% vs. last month"
        changeLabel.textColor = less ? .valeGreen : .valeRed
        accessibilityLabel = "\(titleLabel.text ?? ""), \(amountLabel.text ?? ""), \(changeLabel.text ?? "")"
    }
}
