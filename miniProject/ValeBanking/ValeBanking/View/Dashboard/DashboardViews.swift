//
//  DashboardViews.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

final class AccountTileView: UIView {

    private let titleLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let icon = UIImageView(symbol: "wallet.pass", size: 14, color: .valeGreen)
    private let amountLabel = UILabel(text: "—", font: .vale(20, .medium))

    override init(frame: CGRect) {
        super.init(frame: frame)
        applyCardStyle()
        isAccessibilityElement = true
        amountLabel.adjustsFontSizeToFitWidth = true
        amountLabel.minimumScaleFactor = 0.7
        let top = UIStackView(axis: .horizontal, views: [titleLabel, .spacer(), icon])
        let stack = UIStackView(axis: .vertical, spacing: 8, views: [top, amountLabel])
        addSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ account: Account?) {
        guard let account else { return }
        let shortName = account.isSavings ? "Savings" : "Checking"
        titleLabel.text = "\(shortName) · \(account.last4)"
        icon.image = UIImage(systemName: account.symbol)
        amountLabel.text = Format.money(account.balance)
        accessibilityLabel = "\(shortName), \(amountLabel.text ?? "")"
    }
}

// MARK: - BarChartView

final class BarChartView: UIView {

    private let columns = UIStackView(axis: .horizontal, spacing: 12)
    private let maxBarHeight: CGFloat = 110

    override init(frame: CGRect) {
        super.init(frame: frame)
        columns.distribution = .fillEqually
        columns.alignment = .bottom
        addSubviews(columns)
        columns.pinEdges(to: self)
        isAccessibilityElement = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ weeks: [Spending.Week]) {
        columns.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let biggest = weeks.map(\.amount).max() ?? 1

        for (index, week) in weeks.enumerated() {
            let isLatest = index == weeks.count - 1
            let valueLabel = UILabel(text: Format.money(week.amount).replacingOccurrences(of: ".00", with: ""),
                                     font: .vale(11), color: .valeMuted)
            let nameLabel = UILabel(text: week.label, font: .vale(11), color: .valeMuted)
            valueLabel.textAlignment = .center
            nameLabel.textAlignment = .center

            let bar = UIView()
            bar.backgroundColor = isLatest ? .valeLime : .valeInk
            bar.layer.cornerRadius = 8
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.heightAnchor.constraint(equalToConstant: max(8, maxBarHeight * week.amount / biggest)).isActive = true

            let column = UIStackView(axis: .vertical, spacing: 6, views: [valueLabel, bar, nameLabel])
            columns.addArrangedSubview(column)
        }
        accessibilityLabel = "Weekly spending: " + weeks.map { "\($0.label) \(Format.money($0.amount))" }.joined(separator: ", ")
    }
}

// MARK: - CategoryRowView

final class CategoryRowView: UIView {

    init(name: String, amount: Double, share: Float, color: UIColor) {
        super.init(frame: .zero)
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 2
        let nameLabel = UILabel(text: name, font: .vale(14))
        let amountLabel = UILabel(text: Format.money(amount), font: .vale(14, .medium))

        let progress = UIProgressView(progressViewStyle: .bar)
        progress.progress = share
        progress.progressTintColor = color
        progress.trackTintColor = .valeSoftGreen
        progress.layer.cornerRadius = 2
        progress.clipsToBounds = true

        let top = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, views: [dot, nameLabel, .spacer(), amountLabel])
        let stack = UIStackView(axis: .vertical, spacing: 8, views: [top, progress])
        addSubviews(stack)
        stack.pinEdges(to: self)
        NSLayoutConstraint.activate([
            dot.widthAnchor.constraint(equalToConstant: 8),
            dot.heightAnchor.constraint(equalToConstant: 8),
            progress.heightAnchor.constraint(equalToConstant: 4)
        ])
        isAccessibilityElement = true
        accessibilityLabel = "\(name), \(amountLabel.text ?? "")"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

