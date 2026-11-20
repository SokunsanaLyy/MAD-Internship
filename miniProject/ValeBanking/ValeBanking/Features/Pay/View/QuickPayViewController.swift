//
//  QuickPayViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 5/11/2026.
//

import UIKit

// MARK: - AddQuickPayViewController

final class AddQuickPayViewController: ScrollStackViewController {

    // MARK: - Dependencies

    private let viewModel = AddQuickPayViewModel()

    // MARK: - UI

    private let recentGroup = ListGroupView(title: "People you've paid")
    private let enterTitle = UILabel(text: "OR ENTER THEIR DETAILS", font: .vale(12, .semibold), color: .valeMuted)

    private let methodControl = UISegmentedControl(items: ["Account number", "PayID"])
    private let identifierField = FormFieldView(title: PayeeInput.title(for: .account),
                                                placeholder: PayeeInput.placeholder(for: .account))
    private let findButton = ValeButton("Find person", symbol: "magnifyingglass", style: .outline)

    private let payeeRow = ListRowView(symbol: "person.crop.circle.badge.checkmark", title: "", accessory: .empty)
    private let payeeCard = UIView()
    private let payeeHint = UILabel(text: "Check this is the right person before you save them.",
                                    font: .vale(12), color: .valeMuted, lines: 0)

    private let nicknameField = FormFieldView(title: "Nickname (optional)", placeholder: "e.g. Rent, Mum, Flatmate")
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let saveButton = ValeButton("Save to Quick pay", symbol: "plus", style: .primary)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add to Quick pay"
        setupViews()
        setupActions()
        bindViewModel()
        renderMethod()
        renderPayee(nil)
        renderSuggestions()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.suggestions.isEmpty {
            identifierField.textField.becomeFirstResponder()
        }
    }

    // MARK: - Setup Views

    private func setupViews() {
        contentStack.spacing = 16
        errorLabel.isHidden = true

        methodControl.selectedSegmentIndex = 0
        methodControl.selectedSegmentTintColor = .valeLime

        identifierField.textField.autocorrectionType = .no
        identifierField.textField.autocapitalizationType = .none
        identifierField.textField.returnKeyType = .search

        payeeCard.applyCardStyle(color: .valeSoftGreen, border: false)
        payeeCard.addSubviews(payeeRow)
        payeeRow.pinEdges(to: payeeCard)
        payeeRow.isUserInteractionEnabled = false

        nicknameField.textField.autocapitalizationType = .sentences
        nicknameField.textField.returnKeyType = .done

        let sections: [UIView] = [recentGroup, enterTitle, methodControl, identifierField, findButton,
                                  payeeCard, payeeHint, nicknameField, errorLabel, saveButton]
        sections.forEach(contentStack.addArrangedSubview)
        contentStack.setCustomSpacing(28, after: recentGroup)
        contentStack.setCustomSpacing(10, after: enterTitle)
        contentStack.setCustomSpacing(24, after: payeeHint)
    }

    // MARK: - Setup Actions

    private func setupActions() {
        methodControl.on(.valueChanged) { [weak self] in
            guard let self else { return }
            self.viewModel.method = self.methodControl.selectedSegmentIndex == 0 ? .account : .payid
            self.identifierField.textField.text = ""
            self.renderMethod()
        }
        identifierField.textField.on(.editingChanged) { [weak self] in
            self?.viewModel.clearPayee()
            self?.hideError()
        }
        identifierField.textField.on(.editingDidEndOnExit) { [weak self] in self?.findPerson() }
        findButton.on { [weak self] in self?.findPerson() }

        nicknameField.textField.on(.editingChanged) { [weak self] in self?.hideError() }
        nicknameField.textField.on(.editingDidEndOnExit) { [weak self] in self?.save() }
        saveButton.on { [weak self] in self?.save() }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
    }

    // MARK: - Actions

    private func useRecent(_ recent: RecentPayee) {
        hideError()
        methodControl.selectedSegmentIndex = recent.method == .account ? 0 : 1
        viewModel.method = recent.method
        renderMethod()
        identifierField.textField.text = recent.key
        viewModel.select(recent)
    }

    private func findPerson() {
        view.endEditing(true)
        viewModel.lookUp(identifierField.textField.text ?? "")
    }

    private func save() {
        view.endEditing(true)
        viewModel.save(nickname: nicknameField.textField.text ?? "")
    }

    // MARK: - Render

    private func render(_ state: AddQuickPayViewModel.State) {
        findButton.isLoading = false
        saveButton.isLoading = false

        switch state {
        case .editing:
            renderPayee(nil)
        case .lookingUp:
            findButton.isLoading = true
        case .found(let payee):
            renderPayee(payee)
            nicknameField.textField.becomeFirstResponder()
        case .saving:
            saveButton.isLoading = true
        case .failed(let message, let field):
            errorLabel.text = message
            errorLabel.isHidden = false
            if field == .identifier { identifierField.hasError = true; renderPayee(nil) }
            if field == .nickname { nicknameField.hasError = true }
            UIAccessibility.post(notification: .announcement, argument: message)
        case .saved:
            // No pop-up: going back shows the new card in Quick pay.
            UIAccessibility.post(notification: .announcement, argument: "Saved to Quick pay")
            navigationController?.popViewController(animated: true)
        }
        saveButton.isEnabled = viewModel.payee != nil
    }

    private func renderSuggestions() {
        let suggestions = viewModel.suggestions
        let rows: [UIView] = suggestions.map { recent in
            let symbol = recent.method == .account ? "building.columns" : "at"
            let row = ListRowView(symbol: symbol, title: recent.name,
                                  subtitle: "\(recent.bank) · \(recent.display)", accessory: .chevron)
            row.on { [weak self] in self?.useRecent(recent) }
            return row
        }
        recentGroup.setRows(rows)
        recentGroup.isHidden = suggestions.isEmpty
        enterTitle.isHidden = suggestions.isEmpty
    }

    private func renderMethod() {
        let method = viewModel.method
        identifierField.setTitle(PayeeInput.title(for: method), placeholder: PayeeInput.placeholder(for: method))
        identifierField.textField.keyboardType = method == .account ? .numberPad : .emailAddress
        identifierField.textField.inputAccessoryView = method == .account
            ? UIToolbar.done(action: { [weak self] in self?.findPerson() })
            : nil
        identifierField.textField.reloadInputViews()
        renderPayee(nil)
    }

    private func renderPayee(_ payee: Payee?) {
        payeeCard.isHidden = payee == nil
        payeeHint.isHidden = payee == nil
        nicknameField.isHidden = payee == nil
        saveButton.isEnabled = payee != nil
        if let payee {
            payeeRow.update(title: payee.name, subtitle: "\(payee.bank) · \(payee.display)")
            payeeRow.accessibilityLabel = "\(payee.name), \(payee.bank)"
        }
    }

    private func hideError() {
        errorLabel.isHidden = true
        identifierField.hasError = false
        nicknameField.hasError = false
    }
}
