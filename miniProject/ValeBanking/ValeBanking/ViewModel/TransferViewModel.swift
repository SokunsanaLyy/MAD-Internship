//
//  TransferViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import Foundation

// MARK: - TransferViewModel

final class TransferViewModel {

    enum State {
        case editing
        case sending
        case failed(String)
        case done(Double)
    }

    var onChange: ((State) -> Void)?

    private(set) var state: State = .editing {
        didSet { onChange?(state) }
    }

    private let store = AppStore.shared

    private(set) var fromSavings = false

    var from: Account? { fromSavings ? store.savings : store.checking }
    var to: Account? { fromSavings ? store.checking : store.savings }

    func swapDirection() {
        fromSavings.toggle()
        state = .editing
    }

    func parseAmount(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: ",", with: ""))
    }

    func validationError(for text: String) -> String? {
        guard let from else { return "Your accounts haven't loaded yet." }
        guard let amount = parseAmount(text), amount > 0 else { return "Enter an amount greater than $0." }
        guard amount <= from.balance else { return "That's more than the \(Format.money(from.balance)) available." }
        let decimals = text.split(separator: ".").dropFirst().first?.count ?? 0
        guard decimals <= 2 else { return "Use at most 2 decimal places." }
        return nil
    }

    func submit(amountText: String, note: String) {
        if let message = validationError(for: amountText) {
            state = .failed(message)
            return
        }
        guard let from, let to, let amount = parseAmount(amountText) else { return }

        state = .sending
        Task {
            do {
                try await store.transfer(from: from, to: to, amount: amount,
                                         note: note.trimmingCharacters(in: .whitespaces))
                self.state = .done(amount)
            } catch {
                self.state = .failed(error.localizedDescription)
            }
        }
    }
}

