import UIKit

// SCREEN 5 — Success receipt
// Layout: bank name → tick badge overlapping a receipt card → "Set Schedule" pill → action bar.

final class SuccessViewController: BaseViewController {

    private let store: TransferStore
    private let receipt: TransferSummary

    private let detailsStack = UIStackView()      // rows hidden/shown by the chevron
    private let chevronButton = UIButton(type: .system)
    private var isExpanded = true

    init(store: TransferStore, receipt: TransferSummary) {
        self.store = store
        self.receipt = receipt
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Placeholder — replace with UIImageView(image: UIImage(named: "YourLogo")).
        let bankName = UILabel.make("My Bank", size: 28, weight: .bold, color: .white)

        let scrollView = UIScrollView()
        let card = makeReceiptCard()
        let badge = SuccessBadgeView()

        let schedulePill = makeSchedulePill()
        schedulePill.isHidden = receipt.isScheduled      // already scheduled → no need to offer it

        let actionBar = ActionBarView(items: [
            .init(icon: "house", title: "Home") { [weak self] in self?.goHome() },
            .init(icon: "arrow.clockwise", title: "Repeat") { [weak self] in self?.repeatTransfer(scheduled: false) },
            .init(icon: "wallet.pass", title: "Accounts") { [weak self] in self?.showAccounts() },
            .init(icon: "square.and.arrow.up", title: "Share") { [weak self] in self?.shareReceipt() }
        ])

        let bottomStack = UIStackView(arrangedSubviews: [schedulePill, actionBar])
        bottomStack.axis = .vertical
        bottomStack.alignment = .center
        bottomStack.spacing = 10

        view.addSubviews(bankName, scrollView, bottomStack)
        // The badge sits ON TOP of the card: same scroll view, added after the card, centred on its top edge area.
        scrollView.addSubviews(card, badge)

        NSLayoutConstraint.activate([
            bankName.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            bankName.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: bankName.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -12),

            badge.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            badge.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),

            // Card starts 34pt lower than the badge, so the badge overlaps its top.
            card.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 34),
            card.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -12),
            card.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),

            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            actionBar.widthAnchor.constraint(equalTo: bottomStack.widthAnchor)
        ])
    }

    // MARK: Receipt card

    private func makeReceiptCard() -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16

        let title = UILabel.make(receipt.isScheduled ? "Scheduled" : "Success", size: 17, weight: .semibold, color: .brandNavy)
        title.textAlignment = .center

        // "Transferred to" box
        let transferText = UIStackView(arrangedSubviews: [
            UILabel.make(receipt.isScheduled ? "Will transfer to" : "Transferred to", size: 11, color: .secondaryLabel),
            UILabel.make(receipt.name, size: 15, weight: .bold),
            UILabel.make(receipt.amountText, size: 20, weight: .bold, color: .debitRed)
        ])
        transferText.axis = .vertical
        transferText.spacing = 2
        let transferRow = UIStackView(arrangedSubviews: [InitialsAvatarView(name: receipt.name), transferText])
        transferRow.axis = .horizontal
        transferRow.alignment = .center
        transferRow.spacing = 12
        let transferBox = UIView()
        transferBox.backgroundColor = .surface
        transferBox.layer.cornerRadius = 10
        transferBox.addSubview(transferRow)
        transferRow.pinEdges(to: transferBox, insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))

        // First details row + chevron that shows/hides the rest.
        chevronButton.tintColor = .gold
        chevronButton.accessibilityLabel = "Show or hide details"
        chevronButton.addAction(UIAction { [weak self] _ in self?.toggleDetails() }, for: .touchUpInside)
        let firstRow = UIStackView(arrangedSubviews: [InfoRowView(label: "From Account", value: receipt.name), chevronButton])
        firstRow.axis = .horizontal
        firstRow.alignment = .center
        chevronButton.setContentHuggingPriority(.required, for: .horizontal)

        var rows: [UIView] = [
            InfoRowView(label: "Account No.", value: "\(receipt.fromAccount) (\(receipt.fromCurrency))"),
            InfoRowView(label: "Debit Amount", value: receipt.debitText, valueColor: .debitRed),
            .divider()
        ]
        if let rate = receipt.exchangeRate { rows.append(InfoRowView(label: "Exchange Rate", value: rate)) }
        rows.append(InfoRowView(label: "To Account", value: receipt.name))
        rows.append(InfoRowView(label: "Account No.", value: "\(receipt.toAccount) (\(receipt.toCurrency))"))
        if let purpose = receipt.purpose { rows.append(InfoRowView(label: "Purpose", value: purpose)) }
        if let date = receipt.scheduledFor { rows.append(InfoRowView(label: "Transfer Date", value: date)) }
        rows.append(.divider())
        rows.append(InfoRowView(label: "Reference No.", value: receipt.reference))
        rows.forEach { detailsStack.addArrangedSubview($0) }
        detailsStack.axis = .vertical
        detailsStack.spacing = 8
        updateDetails(animated: false)

        let details = UIStackView(arrangedSubviews: [firstRow, detailsStack])
        details.axis = .vertical
        details.spacing = 8

        let content = UIStackView(arrangedSubviews: [title, transferBox, DashedLineView(), details])
        content.axis = .vertical
        content.spacing = 14

        card.addSubview(content)
        // 38pt extra at the top leaves room under the overlapping badge.
        content.pinEdges(to: card, insets: UIEdgeInsets(top: 16 + 38, left: 16, bottom: 16, right: 16))
        return card
    }

    private func makeSchedulePill() -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = "Set Schedule"
        config.image = UIImage(systemName: "calendar")
        config.imagePadding = 6
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .brandNavy
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var updated = attributes
            updated.font = .app(12, .medium)
            return updated
        }
        let button = UIButton(configuration: config)
        button.addAction(UIAction { [weak self] _ in self?.repeatTransfer(scheduled: true) }, for: .touchUpInside)
        return button
    }

    // MARK: Expand / collapse

    private func toggleDetails() {
        isExpanded.toggle()
        updateDetails(animated: true)
    }

    private func updateDetails(animated: Bool) {
        chevronButton.setImage(UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down"), for: .normal)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.detailsStack.isHidden = !self.isExpanded
                self.view.layoutIfNeeded()        // animates the card growing/shrinking
            }
        } else {
            detailsStack.isHidden = !isExpanded
        }
    }

    // MARK: Actions

    /// Home: go back to the first screen (the menu).
    private func goHome() {
        navigationController?.popToRootViewController(animated: true)
    }

    /// Repeat / Set Schedule: open the form again with the same details. Stack becomes [Menu, Form].
    private func repeatTransfer(scheduled: Bool) {
        guard let navigationController, let menu = navigationController.viewControllers.first else { return }
        store.repeatLast(scheduled: scheduled)
        let form = OwnAccountFormViewController(store: store)
        navigationController.setViewControllers([menu, form], animated: true)
    }

    /// Accounts: the same bottom sheet as Screen 3, read-only, showing the updated balances.
    private func showAccounts() {
        let sheet = SelectAccountViewController(title: "My Accounts", accounts: store.accounts,
                                                selectedID: nil, onSelect: nil)
        present(sheet, animated: true)
    }

    /// Share: opens the iOS share sheet (Messages, Mail, AirDrop…) with a text receipt.
    private func shareReceipt() {
        let activity = UIActivityViewController(activityItems: [receipt.shareText()], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = view     // needed on iPad
        present(activity, animated: true)
    }
}

// MARK: - Success badge
// Navy circle with a gold tick and a white ring.
final class SuccessBadgeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .brandNavy
        layer.cornerRadius = 32
        layer.borderWidth = 4
        layer.borderColor = UIColor.white.cgColor
        isUserInteractionEnabled = false

        let tick = UIImageView(image: UIImage(systemName: "checkmark",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)))
        tick.tintColor = .gold
        addSubviews(tick)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 64),
            heightAnchor.constraint(equalToConstant: 64),
            tick.centerXAnchor.constraint(equalTo: centerXAnchor),
            tick.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        accessibilityLabel = "Success"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Action bar
// Four equal-width buttons with an icon above a label.
final class ActionBarView: UIView {

    struct Item {
        let icon: String
        let title: String
        let action: () -> Void
    }

    init(items: [Item]) {
        super.init(frame: .zero)
        backgroundColor = UIColor.white.withAlphaComponent(0.92)
        layer.cornerRadius = 18

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually      // four equal slots (SwiftUI: .frame(maxWidth: .infinity))

        for item in items {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: item.icon,
                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 17))
            config.title = item.title
            config.imagePlacement = .top
            config.imagePadding = 4
            config.baseForegroundColor = .brandNavy
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
                var updated = attributes
                updated.font = .app(11)
                return updated
            }
            let button = UIButton(configuration: config)
            button.addAction(UIAction { _ in item.action() }, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }

        addSubview(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
