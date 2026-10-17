//
//  VerifyTransactionViewController.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// SCREEN 4 — Verify transaction

// MARK: - Constants
private enum Constants {
    static let panelTitle = "Please verify transaction"
    static let confirmTitle = "Confirm"
    static let confirmScheduleTitle = "Confirm Schedule"

    static let panelTop: CGFloat = 40
    static let panelMargin: CGFloat = 16
    static let panelPadding: CGFloat = 12
    static let panelCornerRadius: CGFloat = 20
    static let panelOpacity: CGFloat = 0.4
    static let cardPadding: CGFloat = 14
    static let rowSpacing: CGFloat = 14
}

final class VerifyTransactionViewController: BaseViewController {

    // MARK: - Dependencies

    private let store: TransferStore
    private let summary: TransferSummary

    // MARK: - UI

    private let headerView = HeaderBarView(title: AppText.transfersTitle)
    private let scrollView = UIScrollView()
    private let panelView = UIView()
    private let panelStack = UIStackView()
    private let confirmButton: PrimaryButton

    // MARK: - Init

    init(store: TransferStore, summary: TransferSummary) {
        self.store = store
        self.summary = summary
        self.confirmButton = PrimaryButton(title: summary.isScheduled ? Constants.confirmScheduleTitle
                                                                      : Constants.confirmTitle)
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

    // MARK: - Setup Views

    private func setupViews() {
        view.addSubviews(headerView, scrollView, confirmButton)
        scrollView.addSubviews(panelView)
        panelView.addSubviews(panelStack)
        setupPanel()
    }

    /// Translucent panel holding the title and the details card.
    private func setupPanel() {
        panelView.backgroundColor = UIColor.white.withAlphaComponent(Constants.panelOpacity)
        panelView.layer.cornerRadius = Constants.panelCornerRadius

        let title = UILabel.make(Constants.panelTitle, size: 15, weight: .semibold, color: .brandNavy)
        title.textAlignment = .center

        panelStack.axis = .vertical
        panelStack.spacing = Constants.panelPadding
        panelStack.addArrangedSubview(title)
        panelStack.addArrangedSubview(makeDetailsCard())
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        let padding = Constants.panelPadding
        panelStack.pinEdges(to: panelView, insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -AppLayout.bottomButtonInset),

            panelView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: Constants.panelTop),
            panelView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -Constants.panelMargin),

            // Confirm sits at the bottom, within thumb reach.
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -AppLayout.bottomButtonInset)
        ]
        + headerView.horizontalConstraints(to: view)
        + scrollView.horizontalConstraints(to: view)
        + confirmButton.horizontalConstraints(to: view, inset: AppLayout.screenPadding)
        + [panelView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: Constants.panelMargin),
           panelView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -Constants.panelMargin)])
    }

    // MARK: - Setup Actions

    private func setupActions() {
        headerView.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        confirmButton.on(.touchUpInside) { [weak self] in self?.confirm() }
    }

    // MARK: - Navigation

    private func confirm() {
        guard let receipt = store.confirm(),
              let navigationController,
              let menu = navigationController.viewControllers.first else { return }

        // Replace the back stack with [Menu, Success]. Form and Verify are removed,
        // so Back on the receipt goes to the menu and the transfer can't be confirmed twice.
        navigationController.setViewControllers([menu, SuccessViewController(store: store, receipt: receipt)],animated: true)
    }

    // MARK: - Builders

    private func makeDetailsCard() -> UIView {
        let card = UIView()
        card.applyCardStyle()

        var rows: [UIView] = [
            makeRecipientRow(),
            // The amount is the biggest text on screen — it's what the user must check.
            DetailRowView(label: "Amount",
                          content: UILabel.make(summary.amountText, size: 20, weight: .bold, color: .gold)),
            .divider(),
            DetailRowView(label: "Transfer From",
                          content: makeNameStack(account: "\(summary.fromAccount) (\(summary.fromCurrency))")),
            .divider()
        ]

        // Optional rows only appear when they apply.
        if let rate = summary.exchangeRate {
            rows.append(DetailRowView(label: "Exchange Rate", content: UILabel.make(rate, size: 12)))
        }
        rows.append(DetailRowView(label: "Debit Amount",
                                  content: UILabel.make(summary.debitText, size: 15, weight: .bold)))
        if let purpose = summary.purpose {
            rows.append(DetailRowView(label: "Purpose", content: UILabel.make(purpose, size: 12, lines: 0)))
        }
        if let date = summary.scheduledFor {
            rows.append(DetailRowView(label: "Transfer Date", content: UILabel.make(date, size: 12, weight: .semibold)))
        }

        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = Constants.rowSpacing
        card.addSubview(stack)
        let padding = Constants.cardPadding
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        return card
    }

    /// Avatar + name + To account.
    private func makeRecipientRow() -> UIView {
        let row = UIStackView(arrangedSubviews: [
            InitialsAvatarView(name: summary.name),
            makeNameStack(account: "\(summary.toAccount) (\(summary.toCurrency))")
        ])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        return row
    }

    /// Bold name with the account number underneath.
    private func makeNameStack(account: String) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            UILabel.make(summary.name, size: 15, weight: .bold),
            UILabel.make(account, size: 12, color: .secondaryLabel)
        ])
        stack.axis = .vertical
        stack.spacing = 2
        return stack
    }
}
