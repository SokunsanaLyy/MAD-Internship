//
//  PayViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 5/11/2026.
//

import UIKit

// MARK: - PayViewController

final class PayViewController: ScrollStackViewController {

    // MARK: - Dependencies

    private let viewModel = PayViewModel()

    // MARK: - UI

    private let quickPayScroll = UIScrollView()
    private let quickPayRow = UIStackView(axis: .horizontal, spacing: 10)
    private let quickPayHint = UILabel(font: .vale(12), color: .valeMuted, lines: 0)

    private let methodControl = UISegmentedControl(items: ["Account number", "PayID"])
    private let identifierField = FormFieldView(title: "Account number", placeholder: "6 to 12 digits")
    private let findButton = ValeButton("Find payee", symbol: "magnifyingglass", style: .outline)

    private let payeeRow = ListRowView(symbol: "person.crop.circle.badge.checkmark", title: "", accessory: .empty)
    private let payeeCard = UIView()
    private let payeeHint = UILabel(text: "Check this is the person you want to pay before you continue.",
                                    font: .vale(12), color: .valeMuted, lines: 0)

    private let fromControl = UISegmentedControl(items: ["Everyday checking", "Savings"])
    private let availableLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let amountField = UITextField()
    private let referenceField = FormFieldView(title: "Reference (optional)", placeholder: "e.g. Dinner")
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let payButton = ValeButton("Pay", symbol: "arrow.right", style: .primary, trailingIcon: true)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupActions()
        bindViewModel()
        renderMethod()
        renderFrom()
        renderPayee(nil)
        AppStore.shared.observe(self) { [weak self] in self?.renderQuickPay() }
    }

    // MARK: - Setup Views

    private func setupNavigation() {
        title = "Pay someone"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close,
                                                            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })
    }

    private func setupViews() {
        contentStack.spacing = 20
        errorLabel.isHidden = true

        methodControl.selectedSegmentIndex = 0
        fromControl.selectedSegmentIndex = 0
        [methodControl, fromControl].forEach { $0.selectedSegmentTintColor = .valeLime }

        identifierField.textField.autocorrectionType = .no
        identifierField.textField.autocapitalizationType = .none
        identifierField.textField.returnKeyType = .search

        payeeCard.applyCardStyle(color: .valeSoftGreen, border: false)
        payeeCard.addSubviews(payeeRow)
        payeeRow.pinEdges(to: payeeCard)
        payeeRow.isUserInteractionEnabled = false
        let payeeSection = UIStackView(axis: .vertical, spacing: 8, views: [payeeCard, payeeHint])

        let toSection = UIStackView(axis: .vertical, spacing: 12,
                                    views: [sectionTitle("To"), methodControl, identifierField, findButton, payeeSection])

        amountField.placeholder = "$0.00"
        amountField.font = .vale(44, .medium)
        amountField.textColor = .valeInk
        amountField.textAlignment = .center
        amountField.keyboardType = .decimalPad
        amountField.accessibilityLabel = "Amount in US dollars"
        amountField.inputAccessoryView = UIToolbar.done { [weak self] in self?.view.endEditing(true) }
        availableLabel.textAlignment = .center

        referenceField.textField.returnKeyType = .done

        let fromSection = UIStackView(axis: .vertical, spacing: 12,
                                      views: [sectionTitle("From"), fromControl, amountField, availableLabel])

        let sections: [UIView] = [makeQuickPaySection(), toSection, fromSection, referenceField, errorLabel, payButton]
        sections.forEach(contentStack.addArrangedSubview)
    }

    /// QUICK PAY
    
    private func makeQuickPaySection() -> UIView {
        quickPayScroll.showsHorizontalScrollIndicator = false
        quickPayScroll.addSubviews(quickPayRow)
        NSLayoutConstraint.activate([
            quickPayRow.topAnchor.constraint(equalTo: quickPayScroll.contentLayoutGuide.topAnchor),
            quickPayRow.bottomAnchor.constraint(equalTo: quickPayScroll.contentLayoutGuide.bottomAnchor),
            quickPayRow.leadingAnchor.constraint(equalTo: quickPayScroll.contentLayoutGuide.leadingAnchor),
            quickPayRow.trailingAnchor.constraint(equalTo: quickPayScroll.contentLayoutGuide.trailingAnchor),
            quickPayRow.heightAnchor.constraint(equalTo: quickPayScroll.frameLayoutGuide.heightAnchor),
            quickPayScroll.heightAnchor.constraint(equalToConstant: 92)
        ])
        return UIStackView(axis: .vertical, spacing: 10,
                           views: [sectionTitle("Quick pay"), quickPayScroll, quickPayHint])
    }

    private func makeAddChip() -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = "Add"
        config.subtitle = "Save someone"
        config.image = UIImage(systemName: "plus.circle.fill")
        config.imagePlacement = .top
        config.imagePadding = 6
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22)
        config.baseForegroundColor = .valeGreen
        config.titleAlignment = .center
        config.background.backgroundColor = .valeSoftGreen
        config.background.strokeColor = .valeGreen
        config.background.strokeWidth = 1
        config.background.cornerRadius = 14
        let titleFont = UIFont.vale(13, .semibold)
        let subtitleFont = UIFont.vale(11)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = titleFont
            return outgoing
        }
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = subtitleFont
            return outgoing
        }
        let chip = UIButton(configuration: config)
        chip.accessibilityLabel = "Add someone to Quick pay"
        chip.widthAnchor.constraint(equalToConstant: 116).isActive = true
        chip.on { [weak self] in
            self?.navigationController?.pushViewController(AddQuickPayViewController(), animated: true)
        }
        return chip
    }

    /// One saved payee: nickname on top, real name underneath.
    private func makeQuickPayChip(_ item: QuickPayee) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = item.nickname
        config.subtitle = item.nickname == item.name ? item.bank : item.name
        config.image = UIImage(systemName: "person.crop.circle.fill")
        config.imagePlacement = .top
        config.imagePadding = 6
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22)
        config.baseForegroundColor = .valeInk
        config.titleAlignment = .center
        config.titleLineBreakMode = .byTruncatingTail
        config.background.backgroundColor = .white
        config.background.strokeColor = .valeBorder
        config.background.strokeWidth = 1
        config.background.cornerRadius = 14
        let titleFont = UIFont.vale(13, .semibold)
        let subtitleFont = UIFont.vale(11)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = titleFont
            return outgoing
        }
        config.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = subtitleFont
            return outgoing
        }

        let chip = UIButton(configuration: config)
        chip.accessibilityLabel = "Quick pay \(item.nickname), \(item.name)"
        chip.widthAnchor.constraint(equalToConstant: 116).isActive = true
        chip.on { [weak self] in self?.useQuickPay(item) }

        // Touch and hold → Remove
        chip.menu = UIMenu(children: [
            UIAction(title: "Remove from Quick pay", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] _ in
                self?.removeQuickPay(item)
            }
        ])
        chip.showsMenuAsPrimaryAction = false
        return chip
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel(text: text.uppercased(), font: .vale(12, .semibold), color: .valeMuted)
        label.accessibilityTraits = .header
        return label
    }

    // MARK: - Setup Actions

    private func setupActions() {
        methodControl.on(.valueChanged) { [weak self] in
            guard let self else { return }
            self.viewModel.method = self.methodControl.selectedSegmentIndex == 0 ? .account : .payid
            self.identifierField.textField.text = ""
            self.renderMethod()
        }
        fromControl.on(.valueChanged) { [weak self] in
            guard let self else { return }
            self.viewModel.fromSavings = self.fromControl.selectedSegmentIndex == 1
            self.renderFrom()
        }

        // Changing the details forgets the old payee, so you can't pay the wrong person
        identifierField.textField.on(.editingChanged) { [weak self] in
            self?.viewModel.clearPayee()
            self?.hideError()
        }
        identifierField.textField.on(.editingDidEndOnExit) { [weak self] in self?.findPayee() }
        findButton.on { [weak self] in self?.findPayee() }

        amountField.on(.editingChanged) { [weak self] in
            self?.formatAmountField()
            self?.hideError()
            self?.renderPayButton()
        }
        referenceField.textField.on(.editingDidEndOnExit) {}
        payButton.on { [weak self] in self?.confirmPayment() }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
    }

    // MARK: - Actions

    private func findPayee() {
        view.endEditing(true)
        viewModel.lookUp(identifierField.textField.text ?? "")
    }

    private func confirmPayment() {
        view.endEditing(true)
        let reference = referenceField.textField.text ?? ""
        guard let amount = viewModel.readyToPay(amountText: amountField.text ?? "", reference: reference),
              let payee = viewModel.payee else { return }

        confirm("Pay \(Format.money(amount)) to \(payee.name)?",
                "\(payee.bank) · \(payee.display)\nPayments can't be cancelled once they're sent.",
                action: "Pay") { [weak self] in
            self?.viewModel.pay(amount: amount, reference: reference)
        }
    }

    private func useQuickPay(_ item: QuickPayee) {
        hideError()
        methodControl.selectedSegmentIndex = item.method == .account ? 0 : 1
        viewModel.method = item.method
        renderMethod()
        identifierField.textField.text = item.key
        viewModel.select(item)                      // → .found, shows the payee card
    }

    private func removeQuickPay(_ item: QuickPayee) {
        Task {
            if let message = await viewModel.removeFromQuickPay(item) {
                showAlert("Couldn't remove", message)
            }
        }
    }

    /// Keeps a "$" in front of the amount: "5" → "$5", "12.5" → "$12.5".
    private func formatAmountField() {
        let digits = (amountField.text ?? "").replacingOccurrences(of: "$", with: "")
        amountField.text = digits.isEmpty ? "" : "$" + digits
    }

    // MARK: - Render

    private func render(_ state: PayViewModel.State) {
        findButton.isLoading = false
        payButton.isLoading = false

        switch state {
        case .editing:
            renderPayee(nil)
        case .lookingUp:
            findButton.isLoading = true
        case .found(let payee):
            renderPayee(payee)
            amountField.becomeFirstResponder()
        case .sending:
            payButton.isLoading = true
        case .failed(let message, let field):
            errorLabel.text = message
            errorLabel.isHidden = false
            if field == .identifier { identifierField.hasError = true; renderPayee(nil) }
            if field == .amount { amountField.shake() }
            if field == .reference { referenceField.hasError = true }
            UIAccessibility.post(notification: .announcement, argument: message)
        case .paid(let amount, let name):
            showAlert("Payment sent", "\(Format.money(amount)) is on its way to \(name).") { [weak self] in
                self?.dismiss(animated: true)
            }
        }
        renderPayButton()
    }

    private func renderQuickPay() {
        quickPayRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        quickPayRow.addArrangedSubview(makeAddChip())        // "+ Add" is always first
        viewModel.quickPay.forEach { quickPayRow.addArrangedSubview(makeQuickPayChip($0)) }
        quickPayHint.text = viewModel.quickPay.isEmpty
            ? "Tap Add to save someone you pay often, like your landlord or a friend."
            : "Tap someone to pay them. Touch and hold to remove."
    }

    private func renderMethod() {
        let isAccount = viewModel.method == .account
        identifierField.setTitle(PayeeInput.title(for: viewModel.method),
                                 placeholder: PayeeInput.placeholder(for: viewModel.method))
        identifierField.textField.keyboardType = isAccount ? .numberPad : .emailAddress
        identifierField.textField.inputAccessoryView = isAccount
            ? UIToolbar.done(action: { [weak self] in self?.view.endEditing(true) })
            : nil
        identifierField.textField.reloadInputViews()
        renderPayee(nil)
    }

    private func renderFrom() {
        if let from = viewModel.from {
            availableLabel.text = "Available: \(Format.money(from.balance))"
        }
        renderPayButton()
    }
    
    private func renderPayee(_ payee: Payee?) {
        payeeCard.isHidden = payee == nil
        payeeHint.isHidden = payee == nil
        if let payee {
            payeeRow.update(title: payee.name, subtitle: "\(payee.bank) · \(payee.display)")
            payeeRow.accessibilityLabel = "Paying \(payee.name), \(payee.bank)"
        }
    }

    private func renderPayButton() {
        let amount = viewModel.parseAmount(amountField.text ?? "") ?? 0
        payButton.setLabel(amount > 0 ? "Pay \(Format.money(amount))" : "Pay")
        payButton.isEnabled = viewModel.payee != nil && amount > 0
    }

    private func hideError() {
        errorLabel.isHidden = true
        identifierField.hasError = false
        referenceField.hasError = false
    }
}
