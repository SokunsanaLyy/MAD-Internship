//
//  UIKitHelper.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import UIKit

// MARK: - UIControl
extension UIControl {
    /// button.on { ... } instead of addTarget/selector.
    func on(_ event: UIControl.Event = .touchUpInside, _ action: @escaping () -> Void) {
        addAction(UIAction { _ in action() }, for: event)
    }
}

// MARK: - UIView
extension UIView {
    /// Adds subviews and switches them to Auto Layout.
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }

    /// Pins this view to all four edges of another view.
    func pinEdges(to other: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Small left-right shake, used for a wrong code or invalid input.
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-10, 10, -8, 8, -4, 4, 0]
        animation.duration = 0.4
        layer.add(animation, forKey: "shake")
    }
}

// MARK: - UIStackView
extension UIStackView {
    convenience init(axis: NSLayoutConstraint.Axis,
                     spacing: CGFloat = 0,
                     alignment: UIStackView.Alignment = .fill,
                     views: [UIView] = []) {
        self.init(arrangedSubviews: views)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
    }
}

// MARK: - UILabel
extension UILabel {
    convenience init(text: String? = nil, font: UIFont, color: UIColor = .valeInk, lines: Int = 1) {
        self.init(frame: .zero)
        self.text = text
        self.font = font
        self.textColor = color
        self.numberOfLines = lines
        self.adjustsFontForContentSizeCategory = true
    }
}

// MARK: - UIImageView
extension UIImageView {
    /// An SF Symbol image view, e.g. UIImageView(symbol: "bell", size: 18)
    convenience init(symbol: String, size: CGFloat, weight: UIImage.SymbolWeight = .regular, color: UIColor = .valeInk) {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        self.init(image: UIImage(systemName: symbol, withConfiguration: config))
        preferredSymbolConfiguration = config      // keeps the size when the symbol is changed later
        tintColor = color
        contentMode = .scaleAspectFit
    }
}

// MARK: - Spacer
extension UIView {
    /// A flexible empty view that pushes stack items apart.
    static func spacer() -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }

    /// A 1pt line used between rows.
    static func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = .valeBorder
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}

// MARK: - UITableView
extension UITableView {
    /// Table header views don't size themselves with Auto Layout. Call this in viewDidLayoutSubviews.
    func sizeHeaderToFit() {
        guard let header = tableHeaderView else { return }
        let target = CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let height = header.systemLayoutSizeFitting(target,
                                                    withHorizontalFittingPriority: .required,
                                                    verticalFittingPriority: .fittingSizeLevel).height
        if header.frame.height != height || header.frame.width != bounds.width {
            header.frame = CGRect(x: 0, y: 0, width: bounds.width, height: height)
            tableHeaderView = header
        }
    }
}

// MARK: - UIViewController
extension UIViewController {
    func showAlert(_ title: String, _ message: String? = nil, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOK?() })
        present(alert, animated: true)
    }

    func confirm(_ title: String, _ message: String?, action: String, destructive: Bool = false, onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: action, style: destructive ? .destructive : .default) { _ in onConfirm() })
        present(alert, animated: true)
    }
}
