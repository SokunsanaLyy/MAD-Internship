import UIKit

// SCREEN 4 — Verify transaction
// Layout: header → translucent panel with title + white details card → Confirm at the bottom.
// The summary is passed in when the screen is created, so it never changes while shown.

final class VerifyTransactionViewController: BaseViewController {

    private let store: TransferStore
    private let summary: TransferSummary

    init(store: TransferStore, summary: TransferSummary) {
        self.store = store
        self.summary = summary
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let header = HeaderBarView(title: "Transfers")
        header.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let scrollView = UIScrollView()

        // Translucent panel around the card.
        let panel = UIView()
        panel.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        panel.layer.cornerRadius = 20

        let panelTitle = UILabel.make("Please verify transaction", size: 15, weight: .semibold, color: .brandNavy)
        panelTitle.textAlignment = .center

        let card = makeDetailsCard()

        let panelStack = UIStackView(arrangedSubviews: [panelTitle, card])
        panelStack.axis = .vertical
        panelStack.spacing = 12

        let confirmButton = PrimaryButton(title: summary.isScheduled ? "Confirm Schedule" : "Confirm")
        confirmButton.addAction(UIAction { [weak self] _ in self?.confirm() }, for: .touchUpInside)

        view.addSubviews(header, scrollView, confirmButton)
        scrollView.addSubviews(panel)
        panel.addSubview(panelStack)
        panelStack.pinEdges(to: panel, insets: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: header.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -12),

            panel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 40),
            panel.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -16),
            panel.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            panel.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),

            // Confirm sits at the bottom, within thumb reach.
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        ])
    }

    // MARK: Details card

    private func makeDetailsCard() -> UIView {
        let card = UIView()
        card.applyCardStyle()

        // Recipient: avatar + name + account
        let recipientText = UIStackView(arrangedSubviews: [
            UILabel.make(summary.name, size: 15, weight: .bold),
            UILabel.make("\(summary.toAccount) (\(summary.toCurrency))", size: 12, color: .secondaryLabel)
        ])
        recipientText.axis = .vertical
        recipientText.spacing = 2
        let recipient = UIStackView(arrangedSubviews: [InitialsAvatarView(name: summary.name), recipientText])
        recipient.axis = .horizontal
        recipient.alignment = .center
        recipient.spacing = 12

        // The amount is the biggest text on screen — it's what the user must check.
        let amount = DetailRowView(label: "Amount",
                                   content: UILabel.make(summary.amountText, size: 20, weight: .bold, color: .gold))

        let fromText = UIStackView(arrangedSubviews: [
            UILabel.make(summary.name, size: 15, weight: .bold),
            UILabel.make("\(summary.fromAccount) (\(summary.fromCurrency))", size: 12, color: .secondaryLabel)
        ])
        fromText.axis = .vertical
        fromText.spacing = 2
        let from = DetailRowView(label: "Transfer From", content: fromText)

        var rows: [UIView] = [recipient, amount, .divider(), from, .divider()]

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
        stack.spacing = 14
        card.addSubview(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))
        return card
    }

    // MARK: Confirm

    private func confirm() {
        guard let receipt = store.confirm(),
              let navigationController,
              let menu = navigationController.viewControllers.first else { return }

        let success = SuccessViewController(store: store, receipt: receipt)

        // Replace the whole back stack with [Menu, Success].
        // Form and Verify are removed, so Back on the receipt goes to the menu
        // and the same transfer can't be confirmed twice.
        navigationController.setViewControllers([menu, success], animated: true)
    }
}
