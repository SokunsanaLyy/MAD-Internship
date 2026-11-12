//
//  OTPCodeView.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import UIKit

final class OTPCodeView: UIView {

    var onChange: ((String) -> Void)?
    var onComplete: ((String) -> Void)?

    var code: String { hiddenField.text ?? "" }

    private let length: Int
    private let isSecure: Bool
    private let hiddenField = UITextField()
    private var boxes: [UILabel] = []
    private let row = UIStackView(axis: .horizontal, spacing: 8)

    init(length: Int = AppConfig.otpLength, secure: Bool = false) {
        self.length = length
        self.isSecure = secure
        super.init(frame: .zero)
        setupViews()
        setupActions()
        render()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Public

    @discardableResult
    override func becomeFirstResponder() -> Bool {
        hiddenField.becomeFirstResponder()
    }

    func clear() {
        hiddenField.text = ""
        render()
    }

    func showError(_ isError: Bool) {
        boxes.forEach { $0.layer.borderColor = (isError ? UIColor.valeRed : UIColor.valeBorder).cgColor }
        if isError { row.shake() }
    }

    // MARK: Setup

    private func setupViews() {
        hiddenField.keyboardType = .numberPad
        hiddenField.textContentType = isSecure ? nil : .oneTimeCode
        hiddenField.alpha = 0.01                        
        hiddenField.accessibilityLabel = isSecure ? "Passcode" : "Verification code"
        

        for _ in 0..<length {
            let box = UILabel(font: .vale(26, .regular))
            box.textAlignment = .center
            box.backgroundColor = .white
            box.layer.cornerRadius = 12
            box.layer.cornerCurve = .continuous
            box.layer.borderWidth = 1
            box.clipsToBounds = true
            box.isAccessibilityElement = false
            boxes.append(box)
            row.addArrangedSubview(box)
        }
        row.distribution = .fillEqually

        addSubviews(hiddenField, row)
        row.pinEdges(to: self)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 56),
            hiddenField.centerXAnchor.constraint(equalTo: centerXAnchor),
            hiddenField.centerYAnchor.constraint(equalTo: centerYAnchor),
            hiddenField.widthAnchor.constraint(equalToConstant: 1),
            hiddenField.heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    private func setupActions() {
        // Keep digits only, max `length`
        hiddenField.on(.editingChanged) { [weak self] in
            guard let self else { return }
            let digits = (self.hiddenField.text ?? "").filter(\.isNumber)
            self.hiddenField.text = String(digits.prefix(self.length))
            self.render()
            self.onChange?(self.code)
            if self.code.count == self.length { self.onComplete?(self.code) }
        }

        // Tapping any box opens the keyboard
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(focus)))
    }

    @objc private func focus() {
        hiddenField.becomeFirstResponder()
    }

    private func render() {
        let digits = Array(code)
        for (index, box) in boxes.enumerated() {
            box.text = index < digits.count ? (isSecure ? "●" : String(digits[index])) : ""
            let isCurrent = index == digits.count
            box.layer.borderColor = (isCurrent ? UIColor.valeGreen : UIColor.valeBorder).cgColor
        }
    }
}

