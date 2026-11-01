//
//  ListRowView.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

// MARK: - IconTileView

final class IconTileView: UIView {

    private let imageView: UIImageView

    init(symbol: String, size: CGFloat = 40, background: UIColor = .valeSoftGreen, tint: UIColor = .valeInk) {
        imageView = UIImageView(symbol: symbol, size: size * 0.4, weight: .medium, color: tint)
        super.init(frame: .zero)
        backgroundColor = background
        layer.cornerRadius = size * 0.3
        layer.cornerCurve = .continuous
        addSubviews(imageView)
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSymbol(_ symbol: String) {
        imageView.image = UIImage(systemName: symbol)
    }
}

// MARK: - ListRowView

final class ListRowView: UIControl {

    enum Accessory {
        case chevron
        case value(String)
        case status(String)
        case toggle(Bool)
        case empty
    }

    let toggle = UISwitch()

    private let icon: IconTileView
    private let titleLabel = UILabel(font: .vale(16, .semibold))
    private let subtitleLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let valueLabel = UILabel(font: .vale(14, .medium), color: .valeMuted)
    private let chevron = UIImageView(symbol: "chevron.right", size: 13, weight: .semibold, color: .valeMuted)

    init(symbol: String, title: String, subtitle: String? = nil, accessory: Accessory = .chevron) {
        icon = IconTileView(symbol: symbol)
        super.init(frame: .zero)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        setupViews()
        setAccessory(accessory)
        isAccessibilityElement = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func update(title: String? = nil, subtitle: String? = nil, symbol: String? = nil) {
        if let title { titleLabel.text = title }
        if let subtitle { subtitleLabel.text = subtitle; subtitleLabel.isHidden = false }
        if let symbol { icon.setSymbol(symbol) }
    }

    func setAccessory(_ accessory: Accessory) {
        valueLabel.isHidden = true
        chevron.isHidden = true
        toggle.isHidden = true
        switch accessory {
        case .chevron:
            chevron.isHidden = false
        case .value(let text):
            valueLabel.text = text
            valueLabel.textColor = .valeMuted
            valueLabel.isHidden = false
            chevron.isHidden = false
        case .status(let text):
            valueLabel.text = text
            valueLabel.textColor = text == "Active" ? .valeGreen : .valeRed
            valueLabel.isHidden = false
            chevron.isHidden = false
        case .toggle(let isOn):
            toggle.isOn = isOn
            toggle.isHidden = false
        case .empty:
            break
        }
    }

    private func setupViews() {
        toggle.onTintColor = .valeLime

        let texts = UIStackView(axis: .vertical, spacing: 2, views: [titleLabel, subtitleLabel])
        let row = UIStackView(axis: .horizontal, spacing: 12, alignment: .center,
                              views: [icon, texts, .spacer(), valueLabel, chevron, toggle])
        row.setCustomSpacing(8, after: valueLabel)
        texts.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addSubviews(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hit = super.hitTest(point, with: event) else { return nil }
        return hit.isDescendant(of: toggle) ? hit : self
    }

    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? UIColor.valeSoftGreen.withAlphaComponent(0.6) : .clear }
    }
}

// MARK: - ListGroupView

final class ListGroupView: UIView {

    private let titleLabel = UILabel(font: .vale(12, .semibold), color: .valeMuted)
    private let card = UIView()
    private let rowsStack = UIStackView(axis: .vertical)

    init(title: String?, rows: [UIView] = []) {
        super.init(frame: .zero)
        titleLabel.text = title?.uppercased()
        titleLabel.isHidden = title == nil
        card.applyCardStyle()
        card.clipsToBounds = true
        card.addSubviews(rowsStack)
        rowsStack.pinEdges(to: card)

        let stack = UIStackView(axis: .vertical, spacing: 10, views: [titleLabel, card])
        addSubviews(stack)
        stack.pinEdges(to: self)
        setRows(rows)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setRows(_ rows: [UIView]) {
        rowsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, row) in rows.enumerated() {
            if index > 0 {
                let divider = UIView.divider()
                let inset = UIView()
                inset.addSubviews(divider)
                NSLayoutConstraint.activate([
                    divider.leadingAnchor.constraint(equalTo: inset.leadingAnchor, constant: 66),
                    divider.trailingAnchor.constraint(equalTo: inset.trailingAnchor),
                    divider.topAnchor.constraint(equalTo: inset.topAnchor),
                    divider.bottomAnchor.constraint(equalTo: inset.bottomAnchor)
                ])
                rowsStack.addArrangedSubview(inset)
            }
            rowsStack.addArrangedSubview(row)
        }
    }
}

// MARK: - ScreenHeaderView

final class ScreenHeaderView: UIView {

    init(title: String, subtitle: String = "Vale banking", trailing: UIView? = nil) {
        super.init(frame: .zero)
        let titleLabel = UILabel(text: title, font: .vale(26, .semibold))
        let subtitleLabel = UILabel(text: subtitle, font: .vale(14), color: .valeMuted)
        titleLabel.accessibilityTraits = .header

        let texts = UIStackView(axis: .vertical, spacing: 2, views: [titleLabel, subtitleLabel])
        var views: [UIView] = [texts, .spacer()]
        if let trailing { views.append(trailing) }
        let row = UIStackView(axis: .horizontal, alignment: .center, views: views)
        addSubviews(row)
        row.pinEdges(to: self)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
