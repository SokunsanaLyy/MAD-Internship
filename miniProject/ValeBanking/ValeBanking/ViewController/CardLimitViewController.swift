//
//  CardLimitViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 10/11/2026.
//

import UIKit

// MARK: - CardLimitsViewController
final class CardLimitsViewController: ScrollStackViewController {

    // MARK: - Dependencies

    private let viewModel = CardLimitsViewModel()

    // MARK: - UI

    private let dailySlider = LimitSliderView(
        title: "Daily spending limit",
        caption: "The most you can spend with this card each day, in shops and online.",
        range: CardLimitsViewModel.dailyRange,
        step: CardLimitsViewModel.dailyStep)

    private let atmSlider = LimitSliderView(
        title: "Daily ATM withdrawal limit",
        caption: "The most cash you can take out each day.",
        range: CardLimitsViewModel.atmRange,
        step: CardLimitsViewModel.atmStep)

    private let lockedNote = UILabel(text: "Your card is locked. New limits apply when you unlock it.",
                                     font: .vale(13), color: .valeMuted, lines: 0)
    private let errorLabel = UILabel(font: .vale(14), color: .valeRed, lines: 0)
    private let saveButton = ValeButton("Save limits", symbol: "checkmark", style: .primary)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupViews()
        setupActions()
        bindViewModel()
        render(.editing)
    }

    // MARK: - Setup Views

    private func setupNavigation() {
        title = "Card limits"
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close,
                                                            primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })
    }

    private func setupViews() {
        contentStack.spacing = 16
        errorLabel.isHidden = true
        lockedNote.isHidden = !viewModel.isCardLocked

        dailySlider.setValue(viewModel.dailySpend)
        atmSlider.setValue(viewModel.atmWithdrawal)

        let sections: [UIView] = [lockedNote, dailySlider, atmSlider, errorLabel, saveButton]
        sections.forEach(contentStack.addArrangedSubview)
        contentStack.setCustomSpacing(24, after: atmSlider)
    }

    // MARK: - Setup Actions

    private func setupActions() {
        dailySlider.onChange = { [weak self] value in self?.viewModel.setDailySpend(value) }
        atmSlider.onChange = { [weak self] value in self?.viewModel.setAtmWithdrawal(value) }
        saveButton.on { [weak self] in self?.viewModel.save() }
    }

    private func bindViewModel() {
        viewModel.onChange = { [weak self] state in self?.render(state) }
    }

    // MARK: - Render

    private func render(_ state: CardLimitsViewModel.State) {
        saveButton.isLoading = false
        errorLabel.isHidden = true

        switch state {
        case .editing:
            break
        case .saving:
            saveButton.isLoading = true     
            return
        case .failed(let message):
            errorLabel.text = message
            errorLabel.isHidden = false
            UIAccessibility.post(notification: .announcement, argument: message)
        case .saved:
            UIAccessibility.post(notification: .announcement, argument: "Card limits saved")
            dismiss(animated: true)
            return
        }
        saveButton.isEnabled = viewModel.hasChanges
    }
}
