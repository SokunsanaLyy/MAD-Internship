//
//  CardViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 2/11/2026.
//

import UIKit

// MARK: - CardViewController (Figma: Card detail)

final class CardViewController: ScrollStackViewController {

    private enum Constants {
        static let comingSoon = "This isn't part of the mini project."
    }

    // MARK: - Dependencies

    private let store = AppStore.shared

    // MARK: - UI

    private let helpButton = makeCircleButton(symbol: "questionmark")
    private let cardView = DebitCardView()
    private let linkedLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let showDetailsButton = ValeButton("Show card details", symbol: "touchid", style: .primary)
    private let lockTile = ValeButton("Lock card", symbol: "lock", style: .tile)
    private let limitsTile = ValeButton("Set limits", symbol: "slider.horizontal.3", style: .tile)
    private let walletTile = ValeButton("Add to wallet", symbol: "wallet.pass", style: .tile)
    private let pinRow = ListRowView(symbol: "key", title: "Change PIN", subtitle: "Choose a new 4-digit card PIN")
    private let controlsRow = ListRowView(symbol: "switch.2", title: "Payment controls",
                                          subtitle: "Online, contactless and overseas payments")
    private let lostRow = ListRowView(symbol: "exclamationmark.shield", title: "Lost or stolen card?",
                                      subtitle: "Report, replace or get urgent help")

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        store.observe(self) { [weak self] in self?.render() }
    }

    // MARK: - Setup Views

    private func setupViews() {
        let linkIcon = UIImageView(symbol: "link", size: 12, color: .valeMuted)
        let linkedRow = UIStackView(axis: .horizontal, spacing: 6, alignment: .center, views: [linkIcon, linkedLabel])
        let linked = UIStackView(axis: .vertical, alignment: .center, views: [linkedRow])

        let caption = UILabel(text: "Verify with biometrics to see number, expiry & CVV.",
                              font: .vale(13), color: .valeMuted, lines: 0)
        caption.textAlignment = .center
        let details = UIStackView(axis: .vertical, spacing: 10, views: [showDetailsButton, caption])

        let tiles = UIStackView(axis: .horizontal, spacing: 10, views: [lockTile, limitsTile, walletTile])
        tiles.distribution = .fillEqually

        let manageTitle = UILabel(text: "Manage your card", font: .vale(20, .semibold))
        manageTitle.accessibilityTraits = .header
        let manage = UIStackView(axis: .vertical, spacing: 12,
                                 views: [manageTitle, ListGroupView(title: nil, rows: [pinRow, controlsRow])])

        let lostCard = UIView()
        lostCard.applyCardStyle(color: .valeSoftGreen, border: false)
        lostCard.clipsToBounds = true
        lostCard.addSubviews(lostRow)
        lostRow.pinEdges(to: lostCard)

        let cardSection = UIStackView(axis: .vertical, spacing: 12, views: [cardView, linked])

        let sections: [UIView] = [ScreenHeaderView(title: "Card detail", trailing: helpButton),
                                  cardSection, details, tiles, manage, lostCard]
        sections.forEach(contentStack.addArrangedSubview)
    }

    // MARK: - Setup Actions

    private func setupActions() {
        lockTile.on { [weak self] in self?.toggleLock() }
        showDetailsButton.on { [weak self] in
            self?.showAlert("Card details are protected",
                            "In the full app this asks for Face ID first, then shows the number, expiry and CVV for 30 seconds.")
        }
        helpButton.accessibilityLabel = "Help"
        helpButton.on { [weak self] in self?.showAlert("Help", "Lock your card if you can't find it. You can unlock it at any time.") }
        [limitsTile, walletTile].forEach { $0.on { [weak self] in self?.showAlert("Coming soon", Constants.comingSoon) } }
        [pinRow, controlsRow, lostRow].forEach { $0.on { [weak self] in self?.showAlert("Coming soon", Constants.comingSoon) } }
    }

    private func toggleLock() {
        guard let card = store.card else { return }
        let lock = !card.isLocked
        let title = lock ? "Lock this card?" : "Unlock this card?"
        let message = lock ? "Payments with this card will be declined until you unlock it." : "You'll be able to pay with this card again."
        confirm(title, message, action: lock ? "Lock" : "Unlock", destructive: lock) { [weak self] in
            self?.setLocked(lock)
        }
    }

    private func setLocked(_ lock: Bool) {
        lockTile.isLoading = true
        Task {
            do {
                try await store.setCardLocked(lock)
                UIAccessibility.post(notification: .announcement, argument: lock ? "Card locked" : "Card unlocked")
            } catch {
                showAlert("Couldn't update your card", error.localizedDescription)
            }
            lockTile.isLoading = false
        }
    }

    // MARK: - Render

    private func render() {
        let card = store.card
        cardView.configure(card)
        if let card, let account = store.account(id: card.linkedAccountId) {
            linkedLabel.text = "\(account.name) \(Format.masked(account.last4))"
        }
        let locked = card?.isLocked ?? false
        lockTile.setLabel(locked ? "Unlock card" : "Lock card", symbol: locked ? "lock.open" : "lock")
        lockTile.isHighlightedTile = !locked
        lockTile.isEnabled = card != nil
        showDetailsButton.isEnabled = !locked && card != nil
    }
}
