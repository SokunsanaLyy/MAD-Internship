//
//  OwnAccountFormViewController.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// SCREEN 2 — Own Accounts form
// Layout: sky background → header → icon badge → white sheet (scrolls) → navy "Ok" bar.
// Rule: user action → update the store → refresh() copies the store into the views.

// MARK: - Constants
private enum Constants {
    static let badgeIcon = "arrow.left.arrow.right"
    static let badgeTitle = "Own Accounts"
    static let fromTitle = "From Account"
    static let toTitle = "To Account"
    static let selectFromTitle = "Select From Account"
    static let selectToTitle = "Select To Account"
    static let purposeTitle = "Purpose"
    static let purposePlaceholder = "Purpose (e.g. Savings)"
    static let scheduleTitle = "Schedule Transfer"
    static let okTitle = "Ok"
    static let balanceErrorPrefix = "Amount is more"     // this message is shown in red

    static let badgeWidth: CGFloat = 120
    static let badgeTop: CGFloat = 8
    static let sheetTop: CGFloat = 16
    static let formSpacing: CGFloat = 18
    static let formTop: CGFloat = 24
    static let formBottom: CGFloat = 20
    static let purposeFieldHeight: CGFloat = 44
}

final class OwnAccountFormViewController: BaseViewController {

    // MARK: - Dependencies

    private let store: TransferStore

    // MARK: - UI

    private let headerView = HeaderBarView(title: AppText.transfersTitle)
    private let badgeView = FeatureBadgeView(icon: Constants.badgeIcon, title: Constants.badgeTitle)
    private let sheetView = UIView()
    private let scrollView = UIScrollView()
    private let okBackground = UIView()

    private let fromDropdown = AccountDropdownView(title: Constants.fromTitle)
    private let toDropdown = AccountDropdownView(title: Constants.toTitle)
    private let amountField = AmountFieldView()
    private let receiveLabel = UILabel.make(size: 12, color: .secondaryLabel)
    private let purposeRow = ToggleRowView(title: Constants.purposeTitle)
    private let purposeField = UITextField()
    private let scheduleRow = ToggleRowView(title: Constants.scheduleTitle)
    private let scheduleControl = UISegmentedControl(items: ScheduleOption.allCases.map(\.label))
    private let messageLabel = UILabel.make(size: 12, color: .secondaryLabel, lines: 0)
    private let okButton = PrimaryButton(title: Constants.okTitle, cornerRadius: 0)

    // Hidden views in a stack view take no space, so show/hide needs no extra code.
    private lazy var formStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            fromDropdown, toDropdown, amountField, receiveLabel,
            purposeRow, purposeField, scheduleRow, scheduleControl, messageLabel
        ])
        stack.axis = .vertical
        stack.spacing = Constants.formSpacing
        return stack
    }()

    // MARK: - Init

    init(store: TransferStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()                      // e.g. coming back from Verify, or after "Repeat"
    }

    // MARK: - Setup Views

    private func setupViews() {
        view.addSubviews(headerView, badgeView, sheetView, okBackground, okButton)
        sheetView.addSubviews(scrollView)
        scrollView.addSubviews(formStack)

        setupSheet()
        setupAmountField()
        setupPurposeField()
        setupScheduleControl()
        messageLabel.textAlignment = .center
    }

    private func setupSheet() {
        sheetView.backgroundColor = .white
        sheetView.roundTopCorners(AppLayout.sheetCornerRadius)
        sheetView.clipsToBounds = true

        scrollView.keyboardDismissMode = .interactive      // drag down to hide the keyboard
        scrollView.alwaysBounceVertical = true

        okBackground.backgroundColor = .brandNavy          // continues under the home indicator
    }

    private func setupAmountField() {
        amountField.textField.inputAccessoryView = makeDoneToolbar()   // number pad has no Return key
    }

    private func setupPurposeField() {
        purposeField.placeholder = Constants.purposePlaceholder
        purposeField.font = .app(15)
        purposeField.borderStyle = .roundedRect
        purposeField.returnKeyType = .done
        purposeField.autocorrectionType = .no
        purposeField.delegate = self
    }

    private func setupScheduleControl() {
        scheduleControl.selectedSegmentTintColor = .brandNavy
        scheduleControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        scrollView.pinEdges(to: sheetView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            badgeView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: Constants.badgeTop),
            badgeView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            badgeView.widthAnchor.constraint(equalToConstant: Constants.badgeWidth),

            sheetView.topAnchor.constraint(equalTo: badgeView.bottomAnchor, constant: Constants.sheetTop),
            sheetView.bottomAnchor.constraint(equalTo: okButton.topAnchor),

            formStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.formTop),
            formStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.formBottom),
            formStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: AppLayout.screenPadding),
            formStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -AppLayout.screenPadding),

            purposeField.heightAnchor.constraint(equalToConstant: Constants.purposeFieldHeight),

            // The Ok bar rides on top of the keyboard when it opens.
            okButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            okBackground.topAnchor.constraint(equalTo: okButton.topAnchor),
            okBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        + headerView.horizontalConstraints(to: view)
        + sheetView.horizontalConstraints(to: view)
        + okButton.horizontalConstraints(to: view)
        + okBackground.horizontalConstraints(to: view))
    }

    // MARK: - Setup Actions

    private func setupActions() {
        headerView.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        fromDropdown.on(.touchUpInside) { [weak self] in self?.pickAccount(isFrom: true) }
        toDropdown.on(.touchUpInside) { [weak self] in self?.pickAccount(isFrom: false) }
        okButton.on(.touchUpInside) { [weak self] in self?.continueToVerify() }

        // Invalid amounts (letters, a 3rd decimal) are ignored by the store;
        // refresh() then puts the last valid text back in the field.
        amountField.textField.on(.editingChanged) { [weak self] in
            guard let self else { return }
            let text = amountField.textField.text ?? ""
            update { $0.setAmountText(text) }
        }
        purposeField.on(.editingChanged) { [weak self] in
            guard let self else { return }
            let text = purposeField.text ?? ""
            update { $0.setPurpose(text) }
        }
        scheduleControl.on(.valueChanged) { [weak self] in
            guard let self, let option = ScheduleOption(rawValue: scheduleControl.selectedSegmentIndex) else { return }
            update { $0.setScheduleOption(option) }
        }

        purposeRow.onChange = { [weak self] isOn in
            self?.update { $0.setPurposeEnabled(isOn) }
            if isOn { self?.purposeField.becomeFirstResponder() }
        }
        scheduleRow.onChange = { [weak self] isOn in
            self?.update { $0.setScheduled(isOn) }
        }
    }

    // MARK: - Navigation

    /// Opens the account sheet (Screen 3). The To list leaves out the From account.
    private func pickAccount(isFrom: Bool) {
        view.endEditing(true)
        let picker = SelectAccountViewController(
            title: isFrom ? Constants.selectFromTitle : Constants.selectToTitle,
            accounts: isFrom ? store.accounts : store.accounts.filter { $0.id != store.fromAccount?.id },
            selectedID: (isFrom ? store.fromAccount : store.toAccount)?.id
        ) { [weak self] account in
            self?.update { isFrom ? $0.selectFrom(account) : $0.selectTo(account) }
        }
        present(picker, animated: true)
    }

    private func continueToVerify() {
        view.endEditing(true)
        guard let summary = store.buildSummary() else { return }      // what was entered right now
        navigationController?.pushViewController(
            VerifyTransactionViewController(store: store, summary: summary), animated: true)
    }

    // MARK: - Refresh

    /// Changes the store, then updates the screen. Every user action goes through here.
    private func update(_ change: (TransferStore) -> Void) {
        change(store)
        refresh()
    }

    /// Copies the store's values into every view.
    private func refresh() {
        fromDropdown.configure(account: store.fromAccount)
        toDropdown.configure(account: store.toAccount)

        if amountField.textField.text != store.amountText { amountField.textField.text = store.amountText }
        amountField.configure(currency: store.fromAccount?.currency)

        receiveLabel.text = receiveText
        receiveLabel.isHidden = receiveText == nil

        purposeRow.toggle.setOn(store.hasPurpose, animated: true)
        purposeField.isHidden = !store.hasPurpose
        if purposeField.text != store.purpose { purposeField.text = store.purpose }

        scheduleRow.toggle.setOn(store.isScheduled, animated: true)
        scheduleControl.isHidden = !store.isScheduled
        scheduleControl.selectedSegmentIndex = store.scheduleOption.rawValue

        // Why Ok is disabled. The balance problem is shown in red.
        let message = store.validationMessage
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        messageLabel.textColor = message?.hasPrefix(Constants.balanceErrorPrefix) == true ? .debitRed : .secondaryLabel
        okButton.isEnabled = store.canContinue
    }

    /// "You'll receive about 0.02 $", only when the two currencies differ.
    private var receiveText: String? {
        guard let from = store.fromAccount, let to = store.toAccount, from.currency != to.currency,
              let credit = store.creditAmount else { return nil }
        return "You'll receive about \(Money.formatAmount(credit, currency: to.currency))"
    }

    // MARK: - Builders

    /// A "Done" bar shown on top of the number pad.
    private func makeDoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in self?.view.endEditing(true) })
        ]
        return toolbar
    }
}

// MARK: - UITextFieldDelegate
extension OwnAccountFormViewController: UITextFieldDelegate {
    // "Done" on the purpose keyboard closes it.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
