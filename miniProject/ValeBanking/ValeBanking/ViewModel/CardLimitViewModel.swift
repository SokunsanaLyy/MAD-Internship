//
//  CardLimitViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 10/11/2026.
//

import Foundation

// MARK: - CardLimitsViewModel
final class CardLimitsViewModel {

    enum State {
        case editing
        case saving
        case failed(String)
        case saved
    }

    static let dailyRange: ClosedRange<Double> = 0...10_000
    static let dailyStep: Double = 100
    static let atmRange: ClosedRange<Double> = 0...2_000
    static let atmStep: Double = 50

    var onChange: ((State) -> Void)?

    private(set) var state: State = .editing {
        didSet { onChange?(state) }
    }

    private let store = AppStore.shared
    private let original: CardLimits

    private(set) var dailySpend: Double
    private(set) var atmWithdrawal: Double

    init() {
        original = AppStore.shared.card?.limits ?? CardLimits(dailySpend: 1_000, atmWithdrawal: 300)
        dailySpend = original.dailySpend
        atmWithdrawal = original.atmWithdrawal
    }

    var hasChanges: Bool {
        dailySpend != original.dailySpend || atmWithdrawal != original.atmWithdrawal
    }

    var isCardLocked: Bool { store.card?.isLocked ?? false }

    func setDailySpend(_ value: Double) {
        dailySpend = value
        state = .editing
    }

    func setAtmWithdrawal(_ value: Double) {
        atmWithdrawal = value
        state = .editing
    }

    func save() {
        guard hasChanges else { return }
        state = .saving
        let limits = CardLimits(dailySpend: dailySpend, atmWithdrawal: atmWithdrawal)
        Task {
            do {
                try await self.store.setCardLimits(limits)
                self.state = .saved
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
}
