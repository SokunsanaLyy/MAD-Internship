//
//  TransferViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 4/11/2026.
//

import UIKit

// MARK: - TransferViewController

final class TransferViewController: ScrollStackViewController {

    // MARK: - Dependencies

    private let viewModel = TransferViewModel()

    // MARK: - UI

    private let fromRow = ListRowView(symbol: "wallet.pass", title: "From", accessory: .empty)
    private let toRow = ListRowView(symbol: "leaf", title: "To", accessory: .empty)
    private let swapButton = makeCircleButton(symbol: "arrow.up.arrow.down", size: 40)
    private let amountField = UITextField()
    private let availableLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let noteField = FormFieldView(title: "Note (optional)", placeholder: "e.g. Rent savings")
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let sendButton = ValeButton("Transfer", symbol: "arrow.right", style: .primary, trailingIcon: true)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupActions()
        bindViewModel()
        renderAccounts()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountField.becomeFirstResponder()
    }

    // MARK: - Setup Views

    private func setupNavigation() {
        title = "Transfer between accounts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close,
                                                            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })
    }

    private func setupViews() {
        errorLabel.isHidden = true
        swapButton.accessibilityLabel = "Swap accounts"

        let accounts = ListGroupView(title: nil, rows: [fromRow, toRow])
        let swapRow = UIStackView(axis: .horizontal, views: [.spacer(), swapButton, .spacer()])
        let accountsSection = UIStackView(axis: .vertical, spacing: -8, views: [accounts, swapRow])

        amountField.placeholder = "$0.00"
        amountField.font = .vale(44, .medium)
        amountField.textColor = .valeInk
        amountField.textAlignment = .center
        amountField.keyboardType = .decimalPad
        amountField.accessibilityLabel = "Amount in US dollars"
        amountField.inputAccessoryView = UIToolbar.done { [weak self] in self?.view.endEditing(true) }
        availableLabel.textAlignment = .center
        let amountSection = UIStackView(axis: .vertical, spacing: 6, views: [amountField, availableLabel])

        noteField.textField.returnKeyType = .done
        noteField.textField.inputAccessoryView = UIToolbar.done { [weak self] in self?.view.endEditing(true) }

        let sections: [UIView] = [accountsSection, amountSection, noteField, errorLabel, sendButton]
        sections.forEach(contentStack.addArrangedSubview)
        contentStack.spacing = 20
    }

    // MARK: - Setup Actions

    private func setupActions() {
        swapButton.on { [weak self] in
            self?.viewModel.swapDirection()
            self?.renderAccounts()
        }
        amountField.on(.editingChanged) { [weak self] in self?.renderAmount() }
        noteField.textField.on(.editingDidEndOnExit) {}
        sendButton.on { [weak self] in self?.submit() }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
    }

    private func submit() {
        view.endEditing(true)
        viewModel.submit(amountText: amountField.text ?? "", note: noteField.textField.text ?? "")
    }

    // MARK: - Render

    private func renderAccounts() {
        if let from = viewModel.from {
            fromRow.update(title: "From  \(from.name)", subtitle: "\(Format.masked(from.last4)) · \(Format.money(from.balance))", symbol: from.symbol)
            availableLabel.text = "Available: \(Format.money(from.balance))"
        }
        if let to = viewModel.to {
            toRow.update(title: "To  \(to.name)", subtitle: "\(Format.masked(to.last4)) · \(Format.money(to.balance))", symbol: to.symbol)
        }
        renderAmount()
    }

    private func renderAmount() {
        errorLabel.isHidden = true
        let amount = viewModel.parseAmount(amountField.text ?? "") ?? 0
        sendButton.setLabel(amount > 0 ? "Transfer \(Format.money(amount))" : "Transfer")
        sendButton.isEnabled = amount > 0
    }

    private func render(_ state: TransferViewModel.State) {
        switch state {
        case .editing:
            sendButton.isLoading = false
        case .sending:
            sendButton.isLoading = true
        case .failed(let message):
            sendButton.isLoading = false
            errorLabel.text = message
            errorLabel.isHidden = false
            amountField.shake()
            UIAccessibility.post(notification: .announcement, argument: message)
        case .done(let amount):
            sendButton.isLoading = false
            showAlert("Transfer complete", "\(Format.money(amount)) moved to \(viewModel.to?.name ?? "your account").") { [weak self] in
                self?.dismiss(animated: true)
            }
        }
    }
}
