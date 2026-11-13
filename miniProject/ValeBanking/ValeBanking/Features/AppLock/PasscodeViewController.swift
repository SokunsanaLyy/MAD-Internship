//
//  PasscodeViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 11/11/2026.
//

import UIKit

// MARK: - PasscodeViewController

final class PasscodeViewController: ScrollStackViewController {

    // MARK: - Dependencies

    private let viewModel: PasscodeViewModel

    // MARK: - UI

    private let logo = IconTileView(symbol: "lock.fill", size: 56, background: .valeInkFill, tint: .valeLime)
    private let titleLabel = UILabel(font: .vale(30, .light), lines: 0)
    private let subtitleLabel = UILabel(font: .vale(15), color: .valeMuted, lines: 0)
    private let codeView = OTPCodeView(length: AppLock.passcodeLength, secure: true)
    private let messageLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let forgotButton = makeTextButton("Forgot passcode? Log out")

    // MARK: - Init

    init(mode: PasscodeViewModel.Mode) {
        viewModel = PasscodeViewModel(mode: mode)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        bindViewModel()
        render(viewModel.step, viewModel.state)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        codeView.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopCountdown()
    }

    // MARK: - Setup Views

    private func setupViews() {
        contentStack.spacing = 16
        contentStack.alignment = .fill
        titleLabel.textAlignment = .center
        subtitleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
        titleLabel.accessibilityTraits = .header
        forgotButton.isHidden = viewModel.mode == .create

        let logoRow = UIStackView(axis: .vertical, alignment: .center, views: [logo])
        let forgotRow = UIStackView(axis: .vertical, alignment: .center, views: [forgotButton])

        let sections: [UIView] = [logoRow, titleLabel, subtitleLabel, codeView, messageLabel, forgotRow]
        sections.forEach(contentStack.addArrangedSubview)
        contentStack.setCustomSpacing(28, after: logoRow)
        contentStack.setCustomSpacing(28, after: subtitleLabel)
        contentStack.setCustomSpacing(24, after: messageLabel)
        contentStack.layoutMargins = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        contentStack.isLayoutMarginsRelativeArrangement = true
    }

    // MARK: - Setup Actions

    private func setupActions() {
        codeView.onComplete = { [weak self] code in self?.viewModel.submit(code) }
        codeView.onChange = { [weak self] _ in self?.clearError() }
        forgotButton.on { [weak self] in self?.confirmLogOut() }
        if viewModel.mode == .change {
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in
                self?.dismiss(animated: true)
            })
        }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] step, state in self?.render(step, state) }
    }

    private func confirmLogOut() {
        confirm("Log out?", "You'll need your email, password and a code to sign in again, then you can set a new passcode.",
                action: "Log out", destructive: true) {
            Task { await SessionStore.shared.signOut() }
        }
    }

    // MARK: - Render

    private func render(_ step: PasscodeViewModel.Step, _ state: PasscodeViewModel.State) {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        switch state {
        case .waiting:
            codeView.clear()
            codeView.isUserInteractionEnabled = true
            messageLabel.isHidden = true
        case .error(let message):
            codeView.clear()
            codeView.showError(true)
            show(message)
        case .lockedOut(let seconds):
            codeView.clear()
            codeView.isUserInteractionEnabled = false
            view.endEditing(true)
            show("Too many wrong tries. Try again in \(seconds) seconds.")
        case .done:
            if viewModel.mode == .change {
                finishChange()
            }
            // create/unlock: AppLock is now .unlocked and SceneDelegate removes this screen.
        }
        if case .waiting = state {
            codeView.becomeFirstResponder()   // keyboard back up after the confirm step or a lockout
        }
    }

    private func finishChange() {
        view.endEditing(true)
        let profile = presentingViewController
        dismiss(animated: true) {
            profile?.showAlert("Passcode changed", "Use your new passcode next time you open Vale.")
        }
    }

    private func show(_ message: String) {
        messageLabel.text = message
        messageLabel.isHidden = false
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func clearError() {
        if case .lockedOut = viewModel.state { return }
        messageLabel.isHidden = true
    }
}
