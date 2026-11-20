//
//  LoginViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 2/11/2026.
//

import UIKit

// MARK: - LoginViewController (Figma: Sign in)

final class LoginViewController: ScrollStackViewController {

    private enum Constants {
        static let title = "Sign in"
        static let subtitle = "Enter your email and password."
        static let notInDemo = "This isn't part of the mini project."
    }

    // MARK: - Dependencies

    private let viewModel = LoginViewModel()

    // MARK: - UI

    private let emailField = FormFieldView(title: "Email address", placeholder: "you@example.com")
    private let passwordField = FormFieldView(title: "Password", placeholder: "Password")
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let loginButton = ValeButton("Log in", symbol: "arrow.right", style: .primary, trailingIcon: true)
    private let passkeyButton = ValeButton("Log in with Passkey", symbol: "faceid", style: .outline)
    private let forgotButton = makeTextButton("Forgot password?")
    private let helpButton = makeTextButton("Need help?", size: 14)
    private let openAccountButton = makeTextButton("Open an account")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Message from an automatic logout (e.g. 401 session expired)
        if let message = SessionStore.shared.pendingMessage {
            showError(message)
            SessionStore.shared.pendingMessage = nil
        }
    }

    // MARK: - Setup Views

    private func setupViews() {
        contentStack.spacing = 0
        setupFields()

        let footer = makeFooter()
        let sections: [UIView] = [makeHeader(), makeTitles(), emailField, passwordField, forgotRow(), errorLabel,
                                  loginButton, passkeyButton, makeOpenAccountRow(), footer]
        sections.forEach(contentStack.addArrangedSubview)

        contentStack.setCustomSpacing(36, after: contentStack.arrangedSubviews[0])
        contentStack.setCustomSpacing(28, after: contentStack.arrangedSubviews[1])
        contentStack.setCustomSpacing(18, after: emailField)
        contentStack.setCustomSpacing(14, after: passwordField)
        contentStack.setCustomSpacing(14, after: contentStack.arrangedSubviews[4])
        contentStack.setCustomSpacing(14, after: errorLabel)
        contentStack.setCustomSpacing(12, after: loginButton)
        contentStack.setCustomSpacing(20, after: passkeyButton)
        contentStack.setCustomSpacing(60, after: contentStack.arrangedSubviews[8])
        errorLabel.isHidden = true
    }

    private func setupFields() {
        emailField.textField.keyboardType = .emailAddress
        emailField.textField.textContentType = .username
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no
        emailField.textField.returnKeyType = .next

        passwordField.addPasswordToggle()
        passwordField.textField.textContentType = .password
        passwordField.textField.returnKeyType = .go
    }

    private func makeHeader() -> UIView {
        let logo = IconTileView(symbol: "leaf.fill", size: 36, background: .valeInk, tint: .valeLime)
        let name = UILabel(text: "vale", font: .vale(26, .medium))
        return UIStackView(axis: .horizontal, spacing: 10, alignment: .center, views: [logo, name, .spacer(), helpButton])
    }

    private func makeTitles() -> UIView {
        let title = UILabel(text: Constants.title, font: .vale(40, .light))
        title.accessibilityTraits = .header
        let subtitle = UILabel(text: Constants.subtitle, font: .vale(16), color: .valeMuted)
        return UIStackView(axis: .vertical, spacing: 8, views: [title, subtitle])
    }

    private func forgotRow() -> UIView {
        UIStackView(axis: .horizontal, views: [.spacer(), forgotButton])
    }

    private func makeOpenAccountRow() -> UIView {
        let label = UILabel(text: "New to Vale?", font: .vale(14), color: .valeMuted)
        let row = UIStackView(axis: .horizontal, spacing: 4, alignment: .center, views: [label, openAccountButton])
        return UIStackView(axis: .vertical, alignment: .center, views: [row])
    }

    private func makeFooter() -> UIView {
        let shield = UIImageView(symbol: "checkmark.shield", size: 12, color: .valeGreen)
        let secure = UILabel(text: "Protected by bank-level security", font: .vale(12), color: .valeMuted)
        let tagline = UILabel(text: "Your money. Your pace.", font: .vale(12), color: .valeMuted)
        let row = UIStackView(axis: .horizontal, spacing: 6, alignment: .center, views: [shield, secure])
        return UIStackView(axis: .vertical, spacing: 6, alignment: .center, views: [row, tagline])
    }

    // MARK: - Setup Actions

    private func setupActions() {
        loginButton.on { [weak self] in self?.submit() }
        emailField.textField.on(.editingDidEndOnExit) { [weak self] in
            self?.passwordField.textField.becomeFirstResponder()
        }
        passwordField.textField.on(.editingDidEndOnExit) { [weak self] in self?.submit() }
        [emailField.textField, passwordField.textField].forEach {
            $0.on(.editingChanged) { [weak self] in self?.hideError() }
        }
        passkeyButton.on { [weak self] in self?.showAlert("Passkey", Constants.notInDemo) }
        forgotButton.on { [weak self] in self?.showAlert("Forgot password", Constants.notInDemo) }
        helpButton.on { [weak self] in self?.showAlert("Need help?", "Demo sign in: any email, password Vale@2026, code 123456.") }
        openAccountButton.on { [weak self] in
            let signUp = SignUpViewController()
            signUp.onCreated = { email in
                self?.emailField.textField.text = email      
            }
            self?.navigationController?.pushViewController(signUp, animated: true)
        }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
    }

    // MARK: - Actions

    private func submit() {
        view.endEditing(true)
        viewModel.signIn(email: emailField.textField.text ?? "", password: passwordField.textField.text ?? "")
    }

    private func render(_ state: LoginViewModel.State) {
        loginButton.isLoading = state.isLoading
        switch state {
        case .idle, .loading:
            break
        case .failed(let message):
            showError(message)
        case .codeSent:
            passwordField.textField.text = ""          // don't keep the password on screen
            navigationController?.pushViewController(VerificationViewController(), animated: true)
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        emailField.hasError = true
        passwordField.hasError = true
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func hideError() {
        errorLabel.isHidden = true
        emailField.hasError = false
        passwordField.hasError = false
    }
}

private extension LoginViewModel.State {
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

