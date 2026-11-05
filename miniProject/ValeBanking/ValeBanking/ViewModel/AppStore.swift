//
//  AppStore.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import Foundation

// MARK: - AppStore

final class AppStore {

    static let shared = AppStore()

    // MARK: - State

    private(set) var user: User?
    private(set) var accounts: [Account] = []
    private(set) var cards: [Card] = []
    private(set) var transactions: [Transaction] = []
    private(set) var spending: Spending?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var quickPay: [QuickPayee] = []
    private(set) var recentPayees: [RecentPayee] = []

    private let service = BankService()

    private init() {}

    // MARK: - Derived values

    var checking: Account? { accounts.first { !$0.isSavings } }
    var savings: Account? { accounts.first { $0.isSavings } }
    var totalBalance: Double { accounts.reduce(0) { $0 + $1.balance } }
    var card: Card? { cards.first }
    var hasData: Bool { !accounts.isEmpty }

    func account(id: String) -> Account? {
        accounts.first { $0.id == id }
    }

    // MARK: - Observers

    private struct Observer {
        weak var owner: AnyObject?
        let handler: () -> Void
    }

    private var observers: [Observer] = []

    func observe(_ owner: AnyObject, handler: @escaping () -> Void) {
        observers.append(Observer(owner: owner, handler: handler))
        handler()
    }

    private func notify() {
        observers.removeAll { $0.owner == nil }
        observers.forEach { $0.handler() }
    }

    // MARK: - Loading

    /// Loads everything the tabs need. Called on sign in and on pull-to-refresh.
    func loadAll() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        notify()

        do {
            user = try await service.fetchUser()
            accounts = try await service.fetchAccounts()
            cards = try await service.fetchCards()
            transactions = try await service.fetchTransactions()
            spending = try await service.fetchSpending()
            quickPay = try await service.fetchQuickPay()
            recentPayees = try await service.fetchRecentPayees()
        } catch APIError.unauthorized(_) {
            // SessionStore has already logged the user out.
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
        notify()
    }

    // MARK: - Actions

    /// Locks or unlocks the card on the server, then updates every screen.
    func setCardLocked(_ locked: Bool) async throws {
        guard let card else { return }
        let updated = try await service.setCard(card.id, locked: locked)
        if let index = cards.firstIndex(where: { $0.id == updated.id }) {
            cards[index] = updated
        }
        notify()
    }
    
    func lookupPayee(method: PayMethod, value: String) async throws -> Payee {
        try await service.lookupPayee(method: method, value: value)
    }

    /// Pays someone, then updates the balance and payment history on every screen.
    func pay(from: Account, to payee: Payee, amount: Double, reference: String) async throws {
        let request = PaymentRequest(fromAccountId: from.id, method: payee.method, payee: payee.key,
                                     payeeName: payee.name, payeeBank: payee.bank, payeeDisplay: payee.display,
                                     amount: amount, reference: reference)
        let result = try await service.pay(request)
        if let index = accounts.firstIndex(where: { $0.id == from.id }) {
            accounts[index].balance -= result.amount
        }
        let entry = Transaction(id: result.id, title: payee.name,
                                category: reference.isEmpty ? "Payment" : reference,
                                date: result.date, amount: -result.amount, icon: "transfer")
        transactions.insert(entry, at: 0)
        if !recentPayees.contains(where: { $0.key == payee.key }) {
            recentPayees.insert(RecentPayee(key: payee.key, method: payee.method, name: payee.name,
                                            bank: payee.bank, display: payee.display, lastPaid: result.date), at: 0)
        }
        notify()
    }

    /// Moves money between the user's own accounts.
    /// After the server confirms, both balances and the payment history update on every screen.
    func transfer(from: Account, to: Account, amount: Double, note: String) async throws {
        let request = TransferRequest(fromAccountId: from.id, toAccountId: to.id, amount: amount, note: note)
        let result = try await service.transfer(request)

        if let index = accounts.firstIndex(where: { $0.id == from.id }) { accounts[index].balance -= result.amount }
        if let index = accounts.firstIndex(where: { $0.id == to.id }) { accounts[index].balance += result.amount }

        // Payment history for Everyday checking: money out if it left checking, in if it arrived.
        let leftChecking = !from.isSavings
        let entry = Transaction(id: result.id,
                                title: leftChecking ? "To \(to.name)" : "From \(from.name)",
                                category: note.isEmpty ? "Own transfer" : note,
                                date: result.date,
                                amount: leftChecking ? -result.amount : result.amount,
                                icon: "own-transfer")
        transactions.insert(entry, at: 0)
        notify()
    }
    
    func isInQuickPay(_ payee: Payee) -> Bool {
        quickPay.contains { $0.key == payee.key }
    }

    func addToQuickPay(_ payee: Payee, nickname: String) async throws {
        let saved = try await service.addQuickPay(payee, nickname: nickname)
        quickPay.append(saved)
        notify()
    }

    func removeFromQuickPay(_ item: QuickPayee) async throws {
        try await service.removeQuickPay(key: item.key)
        quickPay.removeAll { $0.key == item.key }
        notify()
    }

    /// Removes all data from memory (on logout).
    func clear() {
        user = nil
        accounts = []
        cards = []
        transactions = []
        spending = nil
        errorMessage = nil
        notify()
        quickPay = []
        recentPayees = []
    }
}
