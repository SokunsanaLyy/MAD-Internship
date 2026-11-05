//
//  DashboardViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 3/11/2026.
//

import UIKit

// MARK: - DashboardViewController (Figma: Dashboard)

final class DashboardViewController: ScrollStackViewController {

    // MARK: - Dependencies

    private let store = AppStore.shared

    // MARK: - UI

    private let refreshControl = UIRefreshControl()
    private let monthButton = ValeButton("Oct 2026", symbol: "chevron.down", style: .outline, trailingIcon: true)
    private let totalLabel = UILabel(text: "—", font: .vale(40, .medium))
    private let checkingTile = AccountTileView()
    private let savingsTile = AccountTileView()

    private let periodLabel = UILabel(font: .vale(12, .medium), color: .valeMuted)
    private let monthlyLabel = UILabel(text: "—", font: .vale(30, .medium))
    private let changeChip = UILabel(font: .vale(12, .semibold), color: .valeGreen)
    private let chart = BarChartView()
    private let noteLabel = UILabel(font: .vale(13), color: .valeGreen, lines: 0)

    private let categoriesStack = UIStackView(axis: .vertical, spacing: 16)
    private let incomeLabel = UILabel(font: .vale(13), color: .valeMuted)
    private let netLabel = UILabel(font: .vale(24, .medium), color: .valeGreen)

    private let categoryColors: [UIColor] = [.valeInk, .valeGreen, UIColor(hex: 0x8FB996), UIColor(hex: 0xC9D8CB)]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        store.observe(self) { [weak self] in self?.render() }
    }

    // MARK: - Setup Views

    private func setupViews() {
        scrollView.refreshControl = refreshControl
        monthButton.widthAnchor.constraint(equalToConstant: 120).isActive = true
        monthButton.isUserInteractionEnabled = false      // one month in this demo

        let sections: [UIView] = [ScreenHeaderView(title: "Your money", trailing: monthButton),
                                  makeTotalSection(), makeMonthlyCard(), makeCategoriesSection(), makeNetFlowRow()]
        sections.forEach(contentStack.addArrangedSubview)
    }

    private func makeTotalSection() -> UIView {
        let title = UILabel(text: "Total money", font: .vale(14), color: .valeMuted)
        let caption = UILabel(text: "Across your checking and savings", font: .vale(13), color: .valeMuted)
        let tiles = UIStackView(axis: .horizontal, spacing: 10, views: [checkingTile, savingsTile])
        tiles.distribution = .fillEqually
        let stack = UIStackView(axis: .vertical, spacing: 4, views: [title, totalLabel, caption, tiles])
        stack.setCustomSpacing(16, after: caption)
        return stack
    }

    private func makeMonthlyCard() -> UIView {
        let title = UILabel(text: "Monthly spending", font: .vale(15, .medium))
        let top = UIStackView(axis: .horizontal, views: [title, .spacer(), periodLabel])

        changeChip.backgroundColor = .valeSoftGreen
        changeChip.layer.cornerRadius = 10
        changeChip.clipsToBounds = true
        changeChip.heightAnchor.constraint(equalToConstant: 22).isActive = true
        let amountRow = UIStackView(axis: .horizontal, alignment: .center, views: [monthlyLabel, .spacer(), changeChip])

        let leaf = UIImageView(symbol: "leaf", size: 12, color: .valeGreen)
        let noteRow = UIStackView(axis: .horizontal, spacing: 6, alignment: .center, views: [leaf, noteLabel])

        let stack = UIStackView(axis: .vertical, spacing: 14, views: [top, amountRow, chart, noteRow])
        let card = UIView()
        card.applyCardStyle(radius: 20)
        card.addSubviews(stack)
        stack.pinEdges(to: card, insets: UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16))
        return card
    }

    private func makeCategoriesSection() -> UIView {
        let title = UILabel(text: "Where it went", font: .vale(20, .semibold))
        title.accessibilityTraits = .header
        let report = makeTextButton("View report")
        report.on { [weak self] in self?.showAlert("View report", "This isn't part of the mini project.") }
        let header = UIStackView(axis: .horizontal, alignment: .center, views: [title, .spacer(), report])
        return UIStackView(axis: .vertical, spacing: 16, views: [header, categoriesStack])
    }

    private func makeNetFlowRow() -> UIView {
        let title = UILabel(text: "Net cash flow", font: .vale(15, .medium))
        let texts = UIStackView(axis: .vertical, spacing: 2, views: [title, incomeLabel])
        let row = UIStackView(axis: .horizontal, alignment: .center, views: [texts, .spacer(), netLabel])
        return UIStackView(axis: .vertical, spacing: 16, views: [UIView.divider(), row])
    }

    // MARK: - Setup Actions

    private func setupActions() {
        refreshControl.on(.valueChanged) { [weak self] in
            Task { await self?.store.loadAll() }
        }
    }

    // MARK: - Render

    private func render() {
        if !store.isLoading { refreshControl.endRefreshing() }

        totalLabel.text = store.hasData ? Format.money(store.totalBalance) : "—"
        checkingTile.configure(store.checking)
        savingsTile.configure(store.savings)

        guard let spending = store.spending else { return }
        periodLabel.text = spending.periodLabel.uppercased()
        monthlyLabel.text = Format.money(spending.total)
        let less = spending.changePercent < 0
        changeChip.text = "  \(less ? "↘" : "↗") \(abs(spending.changePercent))% \(less ? "less" : "more")  "
        changeChip.textColor = less ? .valeGreen : .valeRed
        noteLabel.text = less ? "You're spending less than last month. Nice work." : "You're spending more than last month."
        chart.configure(spending.weeks)

        let biggest = spending.categories.map(\.amount).max() ?? 1
        categoriesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, category) in spending.categories.enumerated() {
            let row = CategoryRowView(name: category.name,
                                      amount: category.amount,
                                      share: Float(category.amount / biggest),
                                      color: categoryColors[index % categoryColors.count])
            categoriesStack.addArrangedSubview(row)
        }

        incomeLabel.text = "Income this month · \(Format.money(spending.income))"
        netLabel.text = Format.signedMoney(spending.netCashFlow)
        netLabel.textColor = spending.netCashFlow >= 0 ? .valeGreen : .valeRed
    }
}
