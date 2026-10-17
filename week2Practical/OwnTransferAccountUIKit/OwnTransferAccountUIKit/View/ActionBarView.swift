//
//  ActionBarView.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// MARK: - Action bar
final class ActionBarView: UIView {

    struct Item {
        let icon: String
        let title: String
        let action: () -> Void
    }

    init(items: [Item]) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.92)
        layer.cornerRadius = 18

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually      // four equal slots (SwiftUI: .frame(maxWidth: .infinity))

        for item in items {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: item.icon,
                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 17))
            config.title = item.title
            config.imagePlacement = .top
            config.imagePadding = 4
            config.baseForegroundColor = .brandNavy
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var updated = attributes
                updated.font = .app(11)
                return updated
            }
            let button = UIButton(configuration: config)
            button.addAction(UIAction { _ in item.action() }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        addSubview(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
