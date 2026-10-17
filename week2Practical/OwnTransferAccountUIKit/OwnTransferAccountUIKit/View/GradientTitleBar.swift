//
//  GradientTitleBar.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - Gradient title bar
final class GradientTitleBar: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    init(title: String) {
        super.init(frame: .zero)
        let gradient = layer as! CAGradientLayer
        gradient.colors = [UIColor.brandNavy.withAlphaComponent(0.8).cgColor, UIColor.brandNavy.cgColor]

        let label = UILabel.make(title, size: 17, weight: .semibold, color: .white)
        addSubviews(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}


