//
//  ValeButton.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

final class FormFieldView: UIView {

    let textField = UITextField()

    private let titleLabel = UILabel(font: .vale(14, .medium))
    private let box = UIView()

    init(title: String, placeholder: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        textField.placeholder = placeholder
        textField.font = .vale(16)
        textField.textColor = .valeInk
        textField.accessibilityLabel = title
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var hasError = false {
        didSet { box.layer.borderColor = (hasError ? UIColor.valeRed : UIColor.valeBorder).cgColor }
    }

    func addPasswordToggle() {
        textField.isSecureTextEntry = true
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye.slash")
        config.baseForegroundColor = .valeMuted
        let button = UIButton(configuration: config)
        button.accessibilityLabel = "Show password"
        button.on { [weak self, weak button] in
            guard let self else { return }
            self.textField.isSecureTextEntry.toggle()
            let hidden = self.textField.isSecureTextEntry
            button?.configuration?.image = UIImage(systemName: hidden ? "eye.slash" : "eye")
            button?.accessibilityLabel = hidden ? "Show password" : "Hide password"
        }
        textField.rightView = button
        textField.rightViewMode = .always
    }

    private func setupViews() {
        box.applyCardStyle(radius: 14)
        box.addSubviews(textField)

        let stack = UIStackView(axis: .vertical, spacing: 8, views: [titleLabel, box])
        addSubviews(stack)
        stack.pinEdges(to: self)

        NSLayoutConstraint.activate([
            box.heightAnchor.constraint(equalToConstant: AppLayout.fieldHeight),
            textField.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: box.topAnchor),
            textField.bottomAnchor.constraint(equalTo: box.bottomAnchor)
        ])
    }
}
