import UIKit

// SCREEN 2 — Own Accounts form
// Layout: sky background → header → icon badge → white sheet (scrolls) → flat navy "Ok" bar.
//
// UIKit doesn't redraw automatically when data changes (SwiftUI does).
// So this screen follows a simple rule:  user action → update the store → call refresh().
// refresh() copies every value from the store into the views.

final class OwnAccountFormViewController: BaseViewController {

    private let store: TransferStore

    // Views we need to update later are kept as properties.
    private let fromDropdown = AccountDropdownView(title: "From Account")
    private let toDropdown = AccountDropdownView(title: "To Account")
    private let amountField = AmountFieldView()
    private let receiveLabel = UILabel.make(size: 12, color: .secondaryLabel)
    private let purposeRow = ToggleRowView(title: "Purpose")
    private let purposeField = UITextField()
    private let scheduleRow = ToggleRowView(title: "Schedule Transfer")
    private let scheduleControl = UISegmentedControl(items: ScheduleOption.allCases.map(\.label))
    private let messageLabel = UILabel.make(size: 12, color: .secondaryLabel, lines: 0)
    private let okButton = PrimaryButton(title: "Ok", cornerRadius: 0)

    init(store: TransferStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
        connectActions()
    }

    // Runs every time the screen appears — e.g. coming back from Verify, or after "Repeat".
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }

    // MARK: Layout

    private func buildLayout() {
        let header = HeaderBarView(title: "Transfers")
        header.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let badge = FeatureBadgeView(icon: "arrow.left.arrow.right", title: "Own Accounts")

        // White sheet with rounded top corners, holding a scroll view.
        let sheet = UIView()
        sheet.backgroundColor = .white
        sheet.roundTopCorners(24)
        sheet.clipsToBounds = true

        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive        // drag down to hide the keyboard
        scrollView.alwaysBounceVertical = true

        // Purpose text field: hidden until the Purpose switch is on.
        purposeField.placeholder = "Purpose (e.g. Savings)"
        purposeField.font = .app(15)
        purposeField.borderStyle = .roundedRect
        purposeField.returnKeyType = .done
        purposeField.delegate = self
        purposeField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        // Schedule choices: hidden until the Schedule switch is on.
        scheduleControl.selectedSegmentTintColor = .brandNavy
        scheduleControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)

        messageLabel.textAlignment = .center

        // A vertical stack does the layout of the form fields (SwiftUI: VStack(spacing: 18)).
        // Hidden views in a UIStackView take no space, which makes show/hide easy.
        let form = UIStackView(arrangedSubviews: [
            fromDropdown, toDropdown, amountField, receiveLabel,
            purposeRow, purposeField, scheduleRow, scheduleControl, messageLabel
        ])
        form.axis = .vertical
        form.spacing = 18

        // Navy strip behind the Ok bar that continues under the home indicator.
        let okBackground = UIView()
        okBackground.backgroundColor = .brandNavy

        view.addSubviews(header, badge, sheet, okBackground, okButton)
        sheet.addSubviews(scrollView)
        scrollView.addSubviews(form)
        scrollView.pinEdges(to: sheet)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            badge.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 8),
            badge.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            badge.widthAnchor.constraint(equalToConstant: 120),

            sheet.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 16),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: okButton.topAnchor),

            // The form fills the scroll view's width; its height decides how far it scrolls.
            form.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            form.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            form.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            form.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),

            // keyboardLayoutGuide follows the keyboard: the Ok bar rises above it when it opens,
            // and sits just above the home indicator when it's closed.
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            okButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            okBackground.topAnchor.constraint(equalTo: okButton.topAnchor),
            okBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            okBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            okBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Actions

    private func connectActions() {
        // Dropdowns open the account picker (Screen 3) as a bottom sheet.
        fromDropdown.addAction(UIAction { [weak self] _ in self?.pickFromAccount() }, for: .touchUpInside)
        toDropdown.addAction(UIAction { [weak self] _ in self?.pickToAccount() }, for: .touchUpInside)

        // Amount: the delegate blocks invalid characters; editingChanged saves each change.
        amountField.textField.delegate = self
        amountField.textField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.store.setAmountText(self.amountField.textField.text ?? "")
            self.refresh()
        }, for: .editingChanged)

        purposeRow.onChange = { [weak self] isOn in
            self?.store.setPurposeEnabled(isOn)
            self?.refresh()                                            // shows the text field first…
            if isOn { self?.purposeField.becomeFirstResponder() }      // …then opens the keyboard on it
        }
        purposeField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.store.setPurpose(self.purposeField.text ?? "")
            self.refresh()
        }, for: .editingChanged)

        scheduleRow.onChange = { [weak self] isOn in
            self?.store.setScheduled(isOn)
            self?.refresh()
        }
        scheduleControl.addAction(UIAction { [weak self] _ in
            guard let self, let option = ScheduleOption(rawValue: self.scheduleControl.selectedSegmentIndex) else { return }
            self.store.setScheduleOption(option)
        }, for: .valueChanged)

        okButton.addAction(UIAction { [weak self] _ in self?.continueToVerify() }, for: .touchUpInside)

        // Tap anywhere outside a text field to close the keyboard.
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false      // still let buttons and dropdowns receive the tap
        view.addGestureRecognizer(tap)
    }

    private func pickFromAccount() {
        view.endEditing(true)
        let picker = SelectAccountViewController(
            title: "Select From Account",
            accounts: store.accounts,
            selectedID: store.fromAccount?.id
        ) { [weak self] account in
            self?.store.selectFrom(account)
            self?.refresh()
        }
        present(picker, animated: true)
    }

    private func pickToAccount() {
        view.endEditing(true)
        // You can't transfer into the account you're sending from, so it's left out.
        let choices = store.accounts.filter { $0.id != store.fromAccount?.id }
        let picker = SelectAccountViewController(
            title: "Select To Account",
            accounts: choices,
            selectedID: store.toAccount?.id
        ) { [weak self] account in
            self?.store.selectTo(account)
            self?.refresh()
        }
        present(picker, animated: true)
    }

    private func continueToVerify() {
        view.endEditing(true)
        // Build the summary NOW, so Verify shows exactly what was entered at this moment.
        guard let summary = store.buildSummary() else { return }
        let verify = VerifyTransactionViewController(store: store, summary: summary)
        navigationController?.pushViewController(verify, animated: true)
    }

    // MARK: Refresh
    // Copies the store's values into every view. Called after each change.
    private func refresh() {
        fromDropdown.configure(account: store.fromAccount)
        toDropdown.configure(account: store.toAccount)

        if amountField.textField.text != store.amountText {
            amountField.textField.text = store.amountText
        }
        amountField.configure(currency: store.fromAccount?.currency)

        // "You'll receive about …" only when the two currencies differ.
        if let from = store.fromAccount, let to = store.toAccount, let credit = store.creditAmount,
           from.currency != to.currency {
            receiveLabel.text = "You'll receive about \(Money.formatAmount(credit, currency: to.currency))"
            receiveLabel.isHidden = false
        } else {
            receiveLabel.isHidden = true
        }

        purposeRow.toggle.setOn(store.hasPurpose, animated: true)
        purposeField.isHidden = !store.hasPurpose
        if purposeField.text != store.purpose { purposeField.text = store.purpose }

        scheduleRow.toggle.setOn(store.isScheduled, animated: true)
        scheduleControl.isHidden = !store.isScheduled
        scheduleControl.selectedSegmentIndex = store.scheduleOption.rawValue

        // Explain why Ok is disabled. The balance problem is shown in red.
        let message = store.validationMessage
        messageLabel.text = message
        messageLabel.isHidden = message == nil
        messageLabel.textColor = (message?.hasPrefix("Amount is more") == true) ? .debitRed : .secondaryLabel
        okButton.isEnabled = store.canContinue
    }
}

// MARK: - Text field rules
extension OwnAccountFormViewController: UITextFieldDelegate {

    // Called BEFORE each change. Returning false blocks it — used to stop letters,
    // a second ".", or a third decimal in the amount.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField === amountField.textField else { return true }
        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: textRange, with: string)
        return store.isAllowedAmountInput(updated)
    }

    // "Done" on the keyboard closes it (the purpose field has a Done key).
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
