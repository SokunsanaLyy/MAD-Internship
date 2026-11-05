//
//  HomeViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 2/11/2026.
//

import UIKit

// MARK: - HomeViewController (Figma: Home)

final class HomeViewController: UIViewController {

    private enum Constants {
        static let historyTitle = "Payment history"
        static let comingSoon = "This isn't part of the mini project."
    }

    // MARK: - Dependencies

    private let store = AppStore.shared

    // MARK: - UI

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()

    private let bellButton = makeCircleButton(symbol: "bell")
    private let dateLabel = UILabel(font: .vale(12, .semibold), color: .valeMuted)
    private let greetingLabel = UILabel(font: .vale(26, .regular), lines: 0)
    private let balanceCard = BalanceCardView()
    private let payButton = ValeButton("Pay", symbol: "arrow.up.right", style: .lime)
    private let transferButton = ValeButton("Transfer", symbol: "arrow.left.arrow.right", style: .white)
    private let detailsButton = ValeButton("Details", symbol: "ellipsis", style: .white)
    private let spentCard = SpentCardView()
    private let seeAllButton = makeTextButton("See all")
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        store.observe(self) { [weak self] in self?.render() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.sizeHeaderToFit()
    }

    // MARK: - Setup Views

    private func setupViews() {
        view.backgroundColor = .valeBackground
        tableView.backgroundColor = .valeBackground
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.refreshControl = refreshControl
        tableView.tableHeaderView = makeHeader()

        view.addSubviews(tableView)
        tableView.pinEdges(to: view)
    }

    private func makeHeader() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 600))
        errorLabel.isHidden = true

        let topRow = UIStackView(axis: .horizontal, views: [bellButton, .spacer()])
        let greeting = UIStackView(axis: .vertical, spacing: 4, views: [dateLabel, greetingLabel])

        let actions = UIStackView(axis: .horizontal, spacing: 8, views: [payButton, transferButton, detailsButton])
        actions.distribution = .fillEqually

        let historyTitle = UILabel(text: Constants.historyTitle, font: .vale(20, .semibold))
        historyTitle.accessibilityTraits = .header
        let historyRow = UIStackView(axis: .horizontal, alignment: .center, views: [historyTitle, .spacer(), seeAllButton])

        let stack = UIStackView(axis: .vertical, spacing: 18,
                                views: [topRow, greeting, errorLabel, balanceCard, actions, spentCard, historyRow])
        stack.setCustomSpacing(12, after: balanceCard)
        stack.setCustomSpacing(28, after: spentCard)

        header.addSubviews(stack)
        stack.pinEdges(to: header, insets: UIEdgeInsets(top: 8, left: AppLayout.screenPadding,
                                                         bottom: 6, right: AppLayout.screenPadding))
        return header
    }

    // MARK: - Setup Actions

    private func setupActions() {
        refreshControl.on(.valueChanged) { [weak self] in
            Task { await self?.store.loadAll() }
        }
        transferButton.on { [weak self] in self?.openTransfer() }
        detailsButton.on { [weak self] in
            (self?.tabBarController as? MainTabBarController)?.select(.dashboard)
        }
        payButton.on { [weak self] in self?.openPay() }
        bellButton.on { [weak self] in self?.showAlert("Notifications", "You're all caught up.") }
        seeAllButton.on { [weak self] in self?.showAlert("Payment history", Constants.comingSoon) }
        bellButton.accessibilityLabel = "Notifications"
    }

    private func openTransfer() {
        let transfer = UINavigationController(rootViewController: TransferViewController())
        if let sheet = transfer.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(transfer, animated: true)
    }
    
    private func openPay() {
        let pay = UINavigationController(rootViewController: PayViewController())
        if let sheet = pay.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(pay, animated: true)
    }

    // MARK: - Render (called by AppStore on every change)

    private func render() {
        dateLabel.text = Format.todayHeader()
        greetingLabel.text = "\(Format.greeting()), \(store.user?.firstName ?? "there")."
        balanceCard.configure(account: store.checking, cardLocked: store.card?.isLocked ?? false)
        spentCard.configure(store.spending)
        spentCard.isHidden = store.spending == nil
        transferButton.isEnabled = store.hasData

        errorLabel.text = store.errorMessage
        errorLabel.isHidden = store.errorMessage == nil

        if store.isLoading, !store.hasData, !refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        } else if !store.isLoading {
            refreshControl.endRefreshing()
        }

        tableView.reloadData()
        view.setNeedsLayout()            // re-size the header if text changed
    }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.reuseID, for: indexPath) as! TransactionCell
        cell.configure(with: store.transactions[indexPath.row])
        return cell
    }
}
