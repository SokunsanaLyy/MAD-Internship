//
//  SelectAccountViewController.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// SCREEN 3 — Select Account
// A real iOS bottom sheet. It closes when the user picks an account, swipes it down, or taps outside it.
// Also reused read-only by "Accounts" on the Success screen (onSelect = nil).

// MARK: - Constants
private enum Constants {
    static let sheetCornerRadius: CGFloat = 20
    static let titleBarHeight: CGFloat = 52
    static let estimatedRowHeight: CGFloat = 64
}

final class SelectAccountViewController: UIViewController {

    // MARK: - Dependencies

    private let accounts: [Account]
    private let selectedID: UUID?
    private let onSelect: ((Account) -> Void)?

    // MARK: - UI

    private let titleBar: GradientTitleBar
    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Init

    init(title: String, accounts: [Account], selectedID: UUID?, onSelect: ((Account) -> Void)?) {
        self.accounts = accounts
        self.selectedID = selectedID
        self.onSelect = onSelect
        self.titleBar = GradientTitleBar(title: title)
        super.init(nibName: nil, bundle: nil)
        setupSheetPresentation()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Setup Views

    /// Present as a sheet: half height first, can be dragged up to full height.
    private func setupSheetPresentation() {
        modalPresentationStyle = .pageSheet
        guard let sheet = sheetPresentationController else { return }
        sheet.detents = [.medium(), .large()]
        sheet.preferredCornerRadius = Constants.sheetCornerRadius
        sheet.prefersGrabberVisible = false        // the navy title bar replaces the grabber
    }

    private func setupViews() {
        view.backgroundColor = .surface
        view.addSubviews(titleBar, tableView)
        setupTableView()
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.separatorColor = .fieldBorder
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = onSelect != nil       // read-only when there's nothing to pick
        tableView.register(AccountCell.self, forCellReuseIdentifier: AccountCell.reuseID)
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: view.topAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: Constants.titleBarHeight),

            tableView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        + titleBar.horizontalConstraints(to: view)
        + tableView.horizontalConstraints(to: view))
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension SelectAccountViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseID, for: indexPath) as! AccountCell
        let account = accounts[indexPath.row]
        cell.configure(with: account, isSelected: account.id == selectedID)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onSelect?(accounts[indexPath.row])   // tell the form which account was chosen
        dismiss(animated: true)              // close the sheet
    }
}
