//
//  DebitCardView.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

// MARK: - DebitCardView (Card detail)

final class DebitCardView: UIView {

    private let logoLabel = UILabel(text: "vale.", font: .vale(28, .semibold), color: .white)
    private let statusLabel = UILabel(font: .vale(12, .semibold), color: .valeLime)
    private let numberLabel = UILabel(text: "••••  ••••  ••••  ----", font: .monospacedDigitSystemFont(ofSize: 20, weight: .medium), color: .white)
    private let kindLabel = UILabel(text: "Physical debit card", font: .vale(13), color: .valeCardMuted)
    private let holderLabel = UILabel(font: .vale(14, .medium), color: .white)
    private let typeLabel = UILabel(text: "DEBIT", font: .vale(13, .semibold), color: .valeLime)
    private let ring = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(_ card: Card?) {
        guard let card else { return }
        numberLabel.text = "••••  ••••  ••••  \(card.last4)"     // never show the full card number
        holderLabel.text = card.holderName
        typeLabel.text = card.kind.uppercased()
        statusLabel.text = card.isLocked ? "  ● Locked  " : "  ● Active  "
        statusLabel.textColor = card.isLocked ? .white : .valeLime
        statusLabel.backgroundColor = card.isLocked ? .valeRed : UIColor.white.withAlphaComponent(0.12)
        alpha = card.isLocked ? 0.85 : 1
        accessibilityLabel = "\(card.kind) card ending \(card.last4), \(card.isLocked ? "locked" : "active")"
    }

    private func setupViews() {
        applyCardStyle(color: .valeInkFill, radius: 24, border: true, borderColor: .valeCardEdge)
        clipsToBounds = true
        isAccessibilityElement = true

        // Decorative ring in the corner
        ring.layer.borderWidth = 28
        ring.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        ring.layer.cornerRadius = 90

        statusLabel.layer.cornerRadius = 11
        statusLabel.clipsToBounds = true

        let contactless = UIImageView(symbol: "wave.3.right", size: 16, color: .valeCardMuted)
        let top = UIStackView(axis: .horizontal, alignment: .center, views: [logoLabel, .spacer(), statusLabel])
        let number = UIStackView(axis: .horizontal, alignment: .center, views: [numberLabel, .spacer(), contactless])
        let bottom = UIStackView(axis: .horizontal, views: [holderLabel, .spacer(), typeLabel])
        let stack = UIStackView(axis: .vertical, spacing: 6, views: [top, .spacer(), number, kindLabel, .spacer(), bottom])

        addSubviews(ring, stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 200),
            statusLabel.heightAnchor.constraint(equalToConstant: 22),
            ring.widthAnchor.constraint(equalToConstant: 180),
            ring.heightAnchor.constraint(equalToConstant: 180),
            ring.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 50),
            ring.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 60)
        ])
    }
}
