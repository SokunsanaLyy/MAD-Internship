//
//  HeroIllustrationView.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - Hero illustration
final class HeroIllustrationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

        let phone = UIImageView(image: UIImage(systemName: "iphone.gen3",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 80)))
        phone.tintColor = .white
        phone.transform = CGAffineTransform(rotationAngle: -15 * .pi / 180)
        place(phone, x: 0, y: 0)

        let coins: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
            (-60, -30, 26), (55, -45, 30), (62, 25, 22), (-50, 38, 20), (15, -62, 18)
        ]
        for coin in coins {
            let config = UIImage.SymbolConfiguration(pointSize: coin.size)
                .applying(UIImage.SymbolConfiguration(paletteColors: [.white, .gold]))
            place(UIImageView(image: UIImage(systemName: "dollarsign.circle.fill", withConfiguration: config)),
                  x: coin.x, y: coin.y)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func place(_ subview: UIView, x: CGFloat, y: CGFloat) {
        addSubviews(subview)
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor, constant: x),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor, constant: y)
        ])
    }
}
