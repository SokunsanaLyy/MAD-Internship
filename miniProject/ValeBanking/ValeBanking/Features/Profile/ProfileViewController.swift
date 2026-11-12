//
//  ProfileViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 3/11/2026.
//

import UIKit

// MARK: - ProfileViewController (Figma: Profile)

final class ProfileViewController: ScrollStackViewController {

    private enum Constants {
        static let comingSoon = "This isn't part of the mini project."
        static let faceIDKey = "settings.faceIDEnabled"     // a preference, not a secret, so UserDefaults is fine
    }

    // MARK: - Dependencies

    private let store = AppStore.shared

    // MARK: - UI

    private let helpButton = makeCircleButton(symbol: "questionmark")
    private let avatarLabel = UILabel(text: "–", font: .vale(26, .medium))
    private let nameLabel = UILabel(text: "—", font: .vale(24, .medium))
    private let verifiedLabel = UILabel(font: .vale(13, .medium), color: .valeGreen)
    private let editButton = makeCircleButton(symbol: "pencil", size: 36)

    private let accountsGroup = ListGroupView(title: "Linked accounts")
    private let personalRow = ListRowView(symbol: "person", title: "Personal details", subtitle: "Manage your contact information")
    private let securityRow = ListRowView(symbol: "checkmark.shield", title: "Security & sign-in", subtitle: "Password and trusted devices")
    private let faceIDRow = ListRowView(symbol: "faceid", title: "Face ID & Passkey", subtitle: "Sign in without a password",
                                        accessory: .toggle(UserDefaults.standard.bool(forKey: Constants.faceIDKey)))
    private let passcodeRow = ListRowView(symbol: "lock", title: "Change passcode", subtitle: "The 6 digits you use to open Vale")
    
    private let notificationsRow = ListRowView(symbol: "bell", title: "Notifications", subtitle: "Payments, alerts and reminders")
    private let appearanceRow = ListRowView(symbol: "sun.max", title: "Appearance", subtitle: "Theme and text size", accessory: .value("Light"))
    private let logoutButton = UIButton(configuration: .plain())

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        store.observe(self) { [weak self] in self?.render() }
    }

    // MARK: - Setup Views

    private func setupViews() {
        setupLogoutButton()
        let sections: [UIView] = [
            ScreenHeaderView(title: "Your profile", trailing: helpButton),
            makeProfileRow(),
            accountsGroup,
            ListGroupView(title: "Account & security", rows: [personalRow, securityRow, passcodeRow, faceIDRow]),
            ListGroupView(title: "Preferences", rows: [notificationsRow, appearanceRow]),
            logoutButton
        ]
        sections.forEach(contentStack.addArrangedSubview)
    }

    private func makeProfileRow() -> UIView {
        let avatar = UIView()
        avatar.backgroundColor = .valeSoftGreen
        avatar.layer.cornerRadius = 32
        avatar.addSubviews(avatarLabel)
        NSLayoutConstraint.activate([
            avatar.widthAnchor.constraint(equalToConstant: 64),
            avatar.heightAnchor.constraint(equalToConstant: 64),
            avatarLabel.centerXAnchor.constraint(equalTo: avatar.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ])
        let texts = UIStackView(axis: .vertical, spacing: 4, views: [nameLabel, verifiedLabel])
        return UIStackView(axis: .horizontal, spacing: 14, alignment: .center, views: [avatar, texts, .spacer(), editButton])
    }

    private func setupLogoutButton() {
        var config = UIButton.Configuration.plain()
        config.title = "Log out"
        config.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
        config.imagePadding = 8
        config.baseForegroundColor = .valeRed
        let font = UIFont.vale(16, .semibold)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = font
            return outgoing
        }
        logoutButton.configuration = config
        logoutButton.heightAnchor.constraint(equalToConstant: AppLayout.buttonHeight).isActive = true
    }

    // MARK: - Setup Actions

    private func setupActions() {
        logoutButton.on { [weak self] in self?.confirmLogout() }
        faceIDRow.toggle.on(.valueChanged) { [weak self] in
            guard let self else { return }
            UserDefaults.standard.set(self.faceIDRow.toggle.isOn, forKey: Constants.faceIDKey)
        }
        passcodeRow.on { [weak self] in self?.openChangePasscode() }
        helpButton.accessibilityLabel = "Help"
        editButton.accessibilityLabel = "Edit profile"
        let comingSoon: [UIControl] = [helpButton, editButton, personalRow, securityRow, notificationsRow, appearanceRow]
        comingSoon.forEach { $0.on { [weak self] in self?.showAlert("Coming soon", Constants.comingSoon) } }
    }
    
    private func openChangePasscode() {
        let navigation = UINavigationController(rootViewController: PasscodeViewController(mode: .change))
        present(navigation, animated: true)
    }

    private func confirmLogout() {
        confirm("Log out of Vale?", "You'll need your password and a code to sign in again.",
                action: "Log out", destructive: true) { [weak self] in
            self?.logoutButton.configuration?.showsActivityIndicator = true
            Task { await SessionStore.shared.signOut() }    
        }
    }

    // MARK: - Render

    private func render() {
        if let user = store.user {
            avatarLabel.text = user.initial
            nameLabel.text = user.firstName
            verifiedLabel.text = user.verified ? "✓ Verified account holder" : "Not verified yet"
            verifiedLabel.textColor = user.verified ? .valeGreen : .valeMuted
        }

        let rows = store.accounts.map { account in
            ListRowView(symbol: account.symbol,
                        title: account.name,
                        subtitle: "\(Format.masked(account.last4)) · \(Format.money(account.balance))",
                        accessory: .status(account.isActive ? "Active" : account.status.capitalized))
        }
        rows.forEach { $0.on { [weak self] in self?.showAlert("Account details", Constants.comingSoon) } }
        accountsGroup.setRows(rows)
        accountsGroup.isHidden = rows.isEmpty
    }
}

