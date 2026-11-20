//
//  PayViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 5/11/2026.
//

import Foundation

// MARK: - PayViewModel

final class PayViewModel {

    enum Field {
        case identifier, amount, reference
    }

    enum State {
        case editing
        case lookingUp
        case found(Payee)
        case sending
        case failed(String, Field?)
        case paid(amount: Double, name: String)
    }

    var onChange: ((State) -> Void)?

    private(set) var state: State = .editing {
        didSet { onChange?(state) }
    }

    private let store = AppStore.shared

    var method: PayMethod = .account {
        didSet { clearPayee() }
    }

    var fromSavings = false

    private(set) var payee: Payee?

    var from: Account? { fromSavings ? store.savings : store.checking }
    
    var remainingToday: Double? { store.remainingToday }

    var quickPay: [QuickPayee] { store.quickPay }

    // MARK: - Payee

    func lookUp(_ text: String) {
        if let message = PayeeInput.error(for: text, method: method) {
            state = .failed(message, .identifier)
            return
        }
        state = .lookingUp
        let value = PayeeInput.normalise(text, method: method)
        Task {
            do {
                let found = try await self.store.lookupPayee(method: self.method, value: value)
                self.payee = found
                self.state = .found(found)
            } catch {
                self.payee = nil
                self.state = .failed(error.localizedDescription, .identifier)
            }
        }
    }

    func clearPayee() {
        guard payee != nil else { return }
        payee = nil
        state = .editing
    }

    // MARK: - Quick pay

    func select(_ item: QuickPayee) {
        method = item.method
        payee = item.payee
        state = .found(item.payee)
    }

    func removeFromQuickPay(_ item: QuickPayee) async -> String? {
        do {
            try await store.removeFromQuickPay(item)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    // MARK: - Amount

    func parseAmount(_ text: String) -> Double? {
        Double(text.replacingOccurrences(of: "$", with: "")
                   .replacingOccurrences(of: ",", with: ""))
    }

    func amountError(for text: String) -> String? {
        guard let from else { return "Your accounts haven't loaded yet." }
        guard let amount = parseAmount(text), amount > 0 else { return "Enter an amount greater than $0." }
        guard amount <= from.balance else { return "That's more than the \(Format.money(from.balance)) available." }
        if let remaining = remainingToday, let limit = AppStore.shared.dailyLimit, amount > remaining {
            return "This is over your \(Format.money(limit)) daily limit. You can increase it in Card → Card limits."
        }
        let decimals = text.split(separator: ".").dropFirst().first?.count ?? 0
        guard decimals <= 2 else { return "Use at most 2 decimal places." }
        return nil
    }

    func readyToPay(amountText: String, reference: String) -> Double? {
        guard payee != nil else {
            state = .failed("Find the payee first.", .identifier)
            return nil
        }
        if let message = amountError(for: amountText) {
            state = .failed(message, .amount)
            return nil
        }
        if reference.count > 30 {
            state = .failed("Keep the reference to 30 characters.", .reference)
            return nil
        }
        return parseAmount(amountText)
    }

    // MARK: - Pay

    func pay(amount: Double, reference: String) {
        guard let from, let payee else { return }
        state = .sending
        Task {
            do {
                try await self.store.pay(from: from, to: payee, amount: amount,
                                         reference: reference.trimmingCharacters(in: .whitespaces))
                self.state = .paid(amount: amount, name: payee.name)
            } catch {
                self.state = .failed(error.localizedDescription, nil)
            }
        }
    }
}
