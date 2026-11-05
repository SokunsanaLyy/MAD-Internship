//
//  QuickPayViewModel.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 5/11/2026.
//

import Foundation

// MARK: - AddQuickPayViewModel

final class AddQuickPayViewModel {

    enum Field {
        case identifier, nickname
    }

    enum State {
        case editing
        case lookingUp
        case found(Payee)
        case saving
        case failed(String, Field?)
        case saved
    }

    var onChange: ((State) -> Void)?

    private(set) var state: State = .editing {
        didSet { onChange?(state) }
    }

    private let store = AppStore.shared

    var method: PayMethod = .account {
        didSet { clearPayee() }
    }

    private(set) var payee: Payee?

    var suggestions: [RecentPayee] {
        store.recentPayees.filter { !store.isInQuickPay($0.payee) }
    }

    func select(_ recent: RecentPayee) {
        method = recent.method
        payee = recent.payee
        state = .found(recent.payee)
    }

    // MARK: - Look up

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
                if self.store.isInQuickPay(found) {
                    self.payee = nil
                    self.state = .failed("\(found.name) is already in Quick pay.", .identifier)
                } else {
                    self.payee = found
                    self.state = .found(found)
                }
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

    // MARK: - Save

    func save(nickname: String) {
        guard let payee else {
            state = .failed("Find the person first.", .identifier)
            return
        }
        let name = nickname.trimmingCharacters(in: .whitespaces)
        guard name.count <= 20 else {
            state = .failed("Keep the nickname to 20 characters.", .nickname)
            return
        }
        state = .saving
        Task {
            do {
                
                try await self.store.addToQuickPay(payee, nickname: name)
                self.state = .saved
            } catch {
                self.state = .failed(error.localizedDescription, nil)
            }
        }
    }
}
