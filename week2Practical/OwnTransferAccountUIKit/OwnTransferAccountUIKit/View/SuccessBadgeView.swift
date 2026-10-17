//
//  SuccessBadgeView.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - Success badge
final class SuccessBadgeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .brandNavy
        layer.cornerRadius = 32
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        isUserInteractionEnabled = false

        let tick = UIImageView(image: UIImage(systemName: "checkmark",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)))
        tick.tintColor = .gold
        addSubviews(tick)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 64),
            heightAnchor.constraint(equalToConstant: 64),
            tick.centerXAnchor.constraint(equalTo: centerXAnchor),
            tick.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        accessibilityLabel = "Success"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
