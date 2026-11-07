//
//  SignUpViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 6/11/2026.
//

import UIKit

// MARK: - SignUpViewController

final class SignUpViewController: ScrollStackViewController {

    private enum Constants {
        static let title = "Open an account"
        static let subtitle = "It takes less than a minute."
    }

    // MARK: - Dependencies

    private let viewModel = SignUpViewModel()

    /// Login sets this so it can fill in the email after sign-up.
    var onCreated: ((String) -> Void)?

    // MARK: - UI

    private let backButton = makeCircleButton(symbol: "arrow.left")
    private let nameField = FormFieldView(title: "Full name", placeholder: "e.g. Sokunsana Ly")
    private let emailField = FormFieldView(title: "Email address", placeholder: "you@example.com")
    private let phoneField = FormFieldView(title: "Mobile number", placeholder: "e.g. 0400 111 222")
    private let passwordField = FormFieldView(title: "Password", placeholder: "At least 8 characters")
    private let confirmField = FormFieldView(title: "Confirm password", placeholder: "Re-type Password")
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let createButton = ValeButton("Create account", symbol: "arrow.right", style: .primary, trailingIcon: true)

    private var fields: [FormFieldView] { [nameField, emailField, phoneField, passwordField, confirmField] }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        bindViewModel()
    }

    // MARK: - Setup Views

    private func setupViews() {
        contentStack.spacing = 18
        errorLabel.isHidden = true
        setupFields()

        backButton.accessibilityLabel = "Back"
        let topBar = UIStackView(axis: .horizontal, views: [backButton, .spacer()])

        let title = UILabel(text: Constants.title, font: .vale(34, .light), lines: 0)
        title.accessibilityTraits = .header
        let subtitle = UILabel(text: Constants.subtitle, font: .vale(16), color: .valeMuted)
        let titles = UIStackView(axis: .vertical, spacing: 8, views: [title, subtitle])

        let note = UILabel(text: "Your password is sent securely and never stored on this phone.",
                           font: .vale(12), color: .valeMuted, lines: 0)

        let sections: [UIView] = [topBar, titles] + (fields as [UIView]) + [note, errorLabel, createButton]
        sections.forEach(contentStack.addArrangedSubview)
        contentStack.setCustomSpacing(28, after: titles)
    }

    private func setupFields() {
        nameField.textField.textContentType = .name
        nameField.textField.autocapitalizationType = .words

        emailField.textField.keyboardType = .emailAddress
        emailField.textField.textContentType = .username
        emailField.textField.autocapitalizationType = .none
        emailField.textField.autocorrectionType = .no

        phoneField.textField.keyboardType = .phonePad
        phoneField.textField.textContentType = .telephoneNumber

        passwordField.addPasswordToggle()
        passwordField.textField.textContentType = .newPassword      // iOS can suggest a strong password
        confirmField.addPasswordToggle()
        confirmField.textField.textContentType = .newPassword

        // Return key moves to the next field; the last one submits.
        fields.forEach { $0.textField.returnKeyType = .next }
        confirmField.textField.returnKeyType = .go
    }

    // MARK: - Setup Actions

    private func setupActions() {
        backButton.on { [weak self] in self?.navigationController?.popViewController(animated: true) }
        createButton.on { [weak self] in self?.submit() }

        for (index, field) in fields.enumerated() {
            field.textField.on(.editingChanged) { [weak self] in self?.clearErrors() }
            field.textField.on(.editingDidEndOnExit) { [weak self] in
                guard let self else { return }
                if index + 1 < self.fields.count {
                    self.fields[index + 1].textField.becomeFirstResponder()
                } else {
                    self.submit()
                }
            }
        }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
    }

    // MARK: - Actions

    private func submit() {
        view.endEditing(true)
        viewModel.signUp(fullName: nameField.textField.text ?? "",
                         email: emailField.textField.text ?? "",
                         phone: phoneField.textField.text ?? "",
                         password: passwordField.textField.text ?? "",
                         confirmPassword: confirmField.textField.text ?? "")
    }

    // MARK: - Render

    private func render(_ state: SignUpViewModel.State) {
        switch state {
        case .editing:
            createButton.isLoading = false
        case .sending:
            createButton.isLoading = true
        case .failed(let message, let field):
            createButton.isLoading = false
            errorLabel.text = message
            errorLabel.isHidden = false
            if let field { fieldView(for: field).hasError = true }
            UIAccessibility.post(notification: .announcement, argument: message)
        case .created(let email):
            createButton.isLoading = false
            // Clear the passwords from the screen straight away
            passwordField.textField.text = ""
            confirmField.textField.text = ""
            showAlert("Account created", "You can now sign in with \(email).") { [weak self] in
                self?.onCreated?(email)
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func fieldView(for field: SignUpViewModel.Field) -> FormFieldView {
        switch field {
        case .fullName: return nameField
        case .email: return emailField
        case .phone: return phoneField
        case .password: return passwordField
        case .confirmPassword: return confirmField
        }
    }

    private func clearErrors() {
        errorLabel.isHidden = true
        fields.forEach { $0.hasError = false }
    }
}
