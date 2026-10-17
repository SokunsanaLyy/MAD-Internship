//
//  TransferMenuViewController.swift
//  OwnTransferAccountUIKit
//
//  Created by Sokunsana Ly on 18/10/2026.
//

import UIKit

// SCREEN 1 — Transfers menu

// MARK: - Constants
private enum Constants {
    static let infoMessage = "Move money between your own accounts or to others."
    static let comingSoonSuffix = " is coming soon."

    static let heroSize = CGSize(width: 200, height: 150)
    static let tableVerticalInset: CGFloat = 11
    static let estimatedRowHeight: CGFloat = 76
}

final class TransferMenuViewController: BaseViewController {

    // MARK: - Dependencies

    private let store: TransferStore
    private let options = MenuOption.transferOptions

    // MARK: - UI

    private let headerView = HeaderBarView(title: AppText.transfersTitle, showsBack: false, showsInfo: true)
    private let heroView = HeroIllustrationView()
    private let sheetView = UIView()
    private let tableView = UITableView(frame: .zero, style: .plain)

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

    // MARK: - Setup Views

    private func setupViews() {
        view.addSubviews(headerView, heroView, sheetView)
        sheetView.addSubviews(tableView)
        setupSheet()
        setupTableView()
    }

    private func setupSheet() {
        sheetView.backgroundColor = .surface
        sheetView.roundTopCorners(AppLayout.sheetCornerRadius)
    }

    private func setupTableView() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: Constants.tableVerticalInset, left: 0,
                                              bottom: Constants.tableVerticalInset, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)
    }

    // MARK: - Setup Constraints

    private func setupConstraints() {
        tableView.pinEdges(to: sheetView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            heroView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            heroView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            heroView.widthAnchor.constraint(equalToConstant: Constants.heroSize.width),
            heroView.heightAnchor.constraint(equalToConstant: Constants.heroSize.height),

            sheetView.topAnchor.constraint(equalTo: heroView.bottomAnchor),
            sheetView.bottomAnchor.constraint(equalTo: view.bottomAnchor)    // runs under the home indicator
        ]
        + headerView.horizontalConstraints(to: view)
        + sheetView.horizontalConstraints(to: view))
    }

    // MARK: - Setup Actions

    private func setupActions() {
        headerView.onInfo = { [weak self] in self?.showMessage(Constants.infoMessage) }
    }

    // MARK: - Navigation

    private func openOwnAccounts() {
        store.startNew()                                                 // fresh form every time
        navigationController?.pushViewController(OwnAccountFormViewController(store: store), animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TransferMenuViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseID, for: indexPath) as! MenuCell
        cell.configure(with: options[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        if option.title == MenuOption.ownAccountsTitle {
            openOwnAccounts()
        } else {
            showMessage(option.title + Constants.comingSoonSuffix)
        }
    }
}
