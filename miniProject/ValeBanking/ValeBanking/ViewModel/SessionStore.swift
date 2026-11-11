//
//  SessionStore.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 31/10/2026.
//

import Foundation

final class SessionStore {

    static let shared = SessionStore()

    enum State {
        case signedOut
        case signedIn
    }

    private(set) var state: State

    var onChange: ((State) -> Void)?

    var pendingMessage: String?

    private(set) var phoneLast4 = ""

    private var challengeId: String?

    private let service = BankService()

    private init() {
        
        state = KeychainStore.read(KeychainKey.accessToken) == nil ? .signedOut : .signedIn

        APIClient.shared.onUnauthorized = { [weak self] in
            self?.endSession(message: "Your session has expired. Please sign in again.")
        }
    }

    // MARK: - Sign in

    func signIn(email: String, password: String) async throws {
        let response = try await service.login(email: email, password: password)
        challengeId = response.challengeId
        phoneLast4 = response.phoneLast4
    }

    func verify(code: String) async throws {
        guard let challengeId else {
            throw APIError.unauthorized("Please sign in again.")
        }
        let token = try await service.verify(challengeId: challengeId, code: code)
        KeychainStore.save(token.accessToken, for: KeychainKey.accessToken)
        self.challengeId = nil
        setState(.signedIn)
    }

    // MARK: - Sign out

    func signOut() async {
        try? await service.logout()          // tell the server; log out locally even if this fails
        endSession(message: nil)
    }

    private func endSession(message: String?) {
        guard state == .signedIn else { return }
        KeychainStore.delete(KeychainKey.accessToken)
        AppLock.shared.reset()
        AppStore.shared.clear()                     
        pendingMessage = message
        setState(.signedOut)
    }

    private func setState(_ newState: State) {
        state = newState
        onChange?(newState)
    }
}

