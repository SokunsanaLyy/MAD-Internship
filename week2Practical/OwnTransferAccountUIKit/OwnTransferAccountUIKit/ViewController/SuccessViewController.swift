//
//  SuccessViewController.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// SCREEN 5 — Success receipt
// Layout: bank name → tick badge overlapping a receipt card → "Set Schedule" pill → action bar.

// MARK: - Constants
private enum Constants {
    static let successTitle = "Success"
    static let scheduledTitle = "Scheduled"
    static let transferredTo = "Transferred to"
    static let willTransferTo = "Will transfer to"
    static let setScheduleTitle = "Set Schedule"
    static let chevronLabel = "Show or hide details"

    static let bankNameTop: CGFloat = 8
    static let scrollTop: CGFloat = 12
    static let badgeOverlap: CGFloat = 34        // card starts this far below the badge's top
    static let badgeSpace: CGFloat = 38          // extra top padding inside the card, under the badge
    static let cardPadding: CGFloat = 16
    static let cardCornerRadius: CGFloat = 16
    static let boxPadding: CGFloat = 12
    static let boxCornerRadius: CGFloat = 10
    static let bottomSpacing: CGFloat = 10
    static let bottomInset: CGFloat = 8
}

final class SuccessViewController: BaseViewController {

    // MARK: - Dependencies

    private let store: TransferStore
    private let receipt: TransferSummary
    private var isExpanded = true

    // MARK: - UI

    private let bankNameLabel = UILabel.make(AppText.bankName, size: 28, weight: .bold, color: .white)
    private let scrollView = UIScrollView()
    private let cardView = UIView()
    private let badgeView = SuccessBadgeView()
    private let detailsStack = UIStackView()          // rows hidden/shown by the chevron
    private let chevronButton = UIButton(type: .system)
    private let bottomStack = UIStackView()
    private lazy var actionBar = makeActionBar()

    // MARK: - Init

    init(store: TransferStore, receipt: TransferSummary) {
        self.store = store
        self.receipt = receipt
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupActions()
        updateDetails(animated: false)
    }

    // MARK: - Setup Views

    private func setupViews() {
        view.addSubviews(bankNameLabel, scrollView, bottomStack)
        // The badge sits ON TOP of the card: same scroll view, added after the card.
        scrollView.addSubviews(cardView, badgeView)
        setupReceiptCard()
        setupBottomStack()
    }

    private func setupReceiptCard() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = Constants.cardCornerRadius

        let title = UILabel.make(receipt.isScheduled ? Constants.scheduledTitle : Constants.successTitle,
                                 size: 17, weight: .semibold, color: .brandNavy)
        title.textAlignment = .center

        setupDetailsStack()
        let details = UIStackView(arrangedSubviews: [makeFirstDetailsRow(), detailsStack])
        details.axis = .vertical
        details.spacing = 8

        let content = UIStackView(arrangedSubviews: [title, makeTransferBox(), DashedLineView(), details])
        content.axis = .vertical
        content.spacing = 14
        cardView.addSubview(content)

        let padding = Constants.cardPadding
        content.pinEdges(to: cardView, insets: UIEdgeInsets(top: padding + Constants.badgeSpace, left: padding,
                                                            bottom: padding, right: padding))
    }

    /// The collapsible rows. Optional rows are only added when they apply.
    private func setupDetailsStack() {
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
    }

    private func setupBottomStack() {
        let schedulePill = makeSchedulePill()
        schedulePill.isHidden = receipt.isScheduled      // already scheduled → no need to offer it

        bottomStack.addArrangedSubview(schedulePill)
        bottomStack.addArrangedSubview(actionBar)
        bottomStack.axis = .vertical
        bottomStack.alignment = .center
        bottomStack.spacing = Constants.bottomSpacing
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            bankNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.bankNameTop),
            bankNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            scrollView.topAnchor.constraint(equalTo: bankNameLabel.bottomAnchor, constant: Constants.scrollTop),
            scrollView.bottomAnchor.constraint(equalTo: bottomStack.topAnchor, constant: -Constants.scrollTop),

            badgeView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            badgeView.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),

            // Card starts lower than the badge, so the badge overlaps its top.
            cardView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.badgeOverlap),
            cardView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.scrollTop),
            cardView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: AppLayout.screenPadding),
            cardView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -AppLayout.screenPadding),

            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.bottomInset),
            actionBar.widthAnchor.constraint(equalTo: bottomStack.widthAnchor)
        ]
        + scrollView.horizontalConstraints(to: view)
        + bottomStack.horizontalConstraints(to: view, inset: AppLayout.screenPadding))
    }

    // MARK: - Setup Actions

    private func setupActions() {
        chevronButton.on(.touchUpInside) { [weak self] in self?.toggleDetails() }
    }

    // MARK: - Actions

    private func toggleDetails() {
        isExpanded.toggle()
        updateDetails(animated: true)
    }

    private func updateDetails(animated: Bool) {
        chevronButton.setImage(UIImage(systemName: isExpanded ? "chevron.up" : "chevron.down"), for: .normal)
        let hide = !isExpanded
        guard animated else { detailsStack.isHidden = hide; return }
        UIView.animate(withDuration: AppLayout.animationDuration) {
            self.detailsStack.isHidden = hide
            self.view.layoutIfNeeded()            // animates the card growing/shrinking
        }
    }

    /// Share: opens the iOS share sheet (Messages, Mail, AirDrop…) with a text receipt.
    private func shareReceipt() {
        let activity = UIActivityViewController(activityItems: [receipt.shareText()], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = view     // needed on iPad
        present(activity, animated: true)
    }

    // MARK: - Navigation

    /// Home: back to the first screen (the menu).
    private func goHome() {
        navigationController?.popToRootViewController(animated: true)
    }

    /// Repeat / Set Schedule: the form again with the same details. Stack becomes [Menu, Form].
    private func repeatTransfer(scheduled: Bool) {
        guard let navigationController, let menu = navigationController.viewControllers.first else { return }
        store.repeatLast(scheduled: scheduled)
        navigationController.setViewControllers([menu, OwnAccountFormViewController(store: store)], animated: true)
    }

    /// Accounts: the same bottom sheet as Screen 3, read-only, showing the updated balances.
    private func showAccounts() {
        present(SelectAccountViewController(title: "My Accounts", accounts: store.accounts,
                                            selectedID: nil, onSelect: nil), animated: true)
    }

    // MARK: - Builders

    /// Grey box: avatar + "Transferred to" + name + amount.
    private func makeTransferBox() -> UIView {
        let text = UIStackView(arrangedSubviews: [
            UILabel.make(receipt.isScheduled ? Constants.willTransferTo : Constants.transferredTo,
                         size: 11, color: .secondaryLabel),
            UILabel.make(receipt.name, size: 15, weight: .bold),
            UILabel.make(receipt.amountText, size: 20, weight: .bold, color: .debitRed)
        ])
        text.axis = .vertical
        text.spacing = 2

        let row = UIStackView(arrangedSubviews: [InitialsAvatarView(name: receipt.name), text])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        let box = UIView()
        box.backgroundColor = .surface
        box.layer.cornerRadius = Constants.boxCornerRadius
        box.addSubview(row)
        let padding = Constants.boxPadding
        row.pinEdges(to: box, insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        return box
    }

    /// "From Account" row with the chevron that shows/hides the rest.
    private func makeFirstDetailsRow() -> UIView {
        chevronButton.tintColor = .gold
        chevronButton.accessibilityLabel = Constants.chevronLabel
        chevronButton.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [InfoRowView(label: "From Account", value: receipt.name), chevronButton])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func makeSchedulePill() -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = Constants.setScheduleTitle
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
        button.on(.touchUpInside) { [weak self] in self?.repeatTransfer(scheduled: true) }
        return button
    }

    private func makeActionBar() -> ActionBarView {
        ActionBarView(items: [
            .init(icon: "house", title: "Home") { [weak self] in self?.goHome() },
            .init(icon: "arrow.clockwise", title: "Repeat") { [weak self] in self?.repeatTransfer(scheduled: false) },
            .init(icon: "wallet.pass", title: "Accounts") { [weak self] in self?.showAccounts() },
            .init(icon: "square.and.arrow.up", title: "Share") { [weak self] in self?.shareReceipt() }
        ])
    }
}
