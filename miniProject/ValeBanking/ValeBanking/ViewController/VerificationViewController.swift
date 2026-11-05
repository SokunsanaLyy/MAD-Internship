//
//  VerificationViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 2/11/2026.
//

import UIKit

// MARK: - VerificationViewController (Figma: Verification)

final class VerificationViewController: ScrollStackViewController {

    private enum Constants {
        static let title = "Just making sure it's you."
        static let header = "SECURE SIGN IN"
    }

    // MARK: - Dependencies

    private let viewModel = VerificationViewModel()

    // MARK: - UI

    private let backButton = makeCircleButton(symbol: "arrow.left")
    private let codeView = OTPCodeView()
    private let subtitleLabel = UILabel(font: .vale(15), color: .valeMuted, lines: 0)
    private let resendLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let resendButton = makeTextButton("Resend code", size: 13)
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let verifyButton = ValeButton("Verify & continue", symbol: "arrow.right", style: .primary, trailingIcon: true)
    private let helpButton = makeTextButton("Can't access this number? Get help", size: 13)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        bindViewModel()
        viewModel.startCountdown()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        codeView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent { viewModel.stopCountdown() }
    }

    // MARK: - Setup Views

    private func setupViews() {
        contentStack.spacing = 0
        subtitleLabel.text = "Enter the 6-digit code we sent to your phone ending in \(viewModel.phoneLast4)."
        errorLabel.isHidden = true

        let title = UILabel(text: Constants.title, font: .vale(34, .light), lines: 0)
        title.accessibilityTraits = .header
        let phoneIcon = IconTileView(symbol: "iphone", size: 52)
        let iconRow = UIStackView(axis: .horizontal, views: [phoneIcon, .spacer()])

        let resendRow = UIStackView(axis: .horizontal, spacing: 4, alignment: .center,
                                    views: [resendLabel, resendButton, .spacer()])
        let helpRow = UIStackView(axis: .vertical, alignment: .center, views: [helpButton])

        let views: [UIView] = [makeTopBar(), makeProgressBar(), iconRow, title, subtitleLabel,
                               codeView, resendRow, errorLabel, verifyButton, helpRow]
        views.forEach(contentStack.addArrangedSubview)

        contentStack.setCustomSpacing(20, after: views[0])
        contentStack.setCustomSpacing(28, after: views[1])
        contentStack.setCustomSpacing(20, after: iconRow)
        contentStack.setCustomSpacing(12, after: title)
        contentStack.setCustomSpacing(24, after: subtitleLabel)
        contentStack.setCustomSpacing(14, after: codeView)
        contentStack.setCustomSpacing(16, after: resendRow)
        contentStack.setCustomSpacing(16, after: errorLabel)
        contentStack.setCustomSpacing(16, after: verifyButton)
    }

    private func makeTopBar() -> UIView {
        backButton.accessibilityLabel = "Back"
        let header = UILabel(text: Constants.header, font: .vale(13, .semibold), color: .valeMuted)
        header.textAlignment = .center
        let shield = UIImageView(symbol: "checkmark.shield", size: 18, color: .valeGreen)
        shield.widthAnchor.constraint(equalToConstant: 44).isActive = true
        let bar = UIStackView(axis: .horizontal, alignment: .center, views: [backButton, header, shield])
        bar.distribution = .equalCentering
        return bar
    }

    /// Two-step progress: step 1 done (ink), step 2 current (lime).
    private func makeProgressBar() -> UIView {
        let done = UIView()
        done.backgroundColor = .valeInk
        let current = UIView()
        current.backgroundColor = .valeLime
        [done, current].forEach {
            $0.layer.cornerRadius = 2
            $0.heightAnchor.constraint(equalToConstant: 4).isActive = true
        }
        let row = UIStackView(axis: .horizontal, spacing: 6, views: [done, current])
        row.distribution = .fillEqually
        row.isAccessibilityElement = true
        row.accessibilityLabel = "Step 2 of 2"
        return row
    }

    // MARK: - Setup Actions

    private func setupActions() {
        backButton.on { [weak self] in self?.navigationController?.popViewController(animated: true) }
        verifyButton.on { [weak self] in
            guard let self else { return }
            self.viewModel.verify(code: self.codeView.code)
        }
        codeView.onChange = { [weak self] _ in self?.hideError() }
        codeView.onComplete = { [weak self] code in self?.viewModel.verify(code: code) }   // auto-submit
        resendButton.on { [weak self] in
            self?.viewModel.startCountdown()
            self?.showAlert("Code sent", "We've sent a new code to your phone. (Demo code: 123456)")
        }
        helpButton.on { [weak self] in self?.showAlert("Get help", "This isn't part of the mini project.") }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
        viewModel.onTick = { [weak self] seconds in self?.renderCountdown(seconds) }
    }

    // MARK: - Render

    private func render(_ state: VerificationViewModel.State) {
        switch state {
        case .idle:
            verifyButton.isLoading = false
        case .loading:
            verifyButton.isLoading = true
        case .failed(let message):
            verifyButton.isLoading = false
            errorLabel.text = message
            errorLabel.isHidden = false
            codeView.clear()
            codeView.showError(true)
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    private func renderCountdown(_ seconds: Int) {
        let canResend = seconds <= 0
        resendLabel.text = canResend ? "Didn't get a code?" : String(format: "Didn't get a code? Resend in 00:%02d", seconds)
        resendButton.isHidden = !canResend
    }

    private func hideError() {
        errorLabel.isHidden = true
    }
}
