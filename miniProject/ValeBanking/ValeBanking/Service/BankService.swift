//
//  BankService.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 1/11/2026.
//

import Foundation

// MARK: - BankService
struct BankService {

    private let client = APIClient.shared

    // MARK: Auth

    /// POST /auth/login → sends a 6-digit code to the user's phone
    func login(email: String, password: String) async throws -> LoginResponse {
        try await client.send(.post, "auth/login",
                              body: LoginRequest(email: email, password: password),
                              authorized: false)
    }

    /// POST /auth/verify → returns the access token
    func verify(challengeId: String, code: String) async throws -> TokenResponse {
        try await client.send(.post, "auth/verify",
                              body: VerifyRequest(challengeId: challengeId, code: code),
                              authorized: false)
    }

    func logout() async throws {
        try await client.sendWithoutResponse(.post, "auth/logout")
    }

    // MARK: Data

    func fetchUser() async throws -> User {
        try await client.get("me")
    }

    func fetchAccounts() async throws -> [Account] {
        try await client.get("accounts")
    }

    func fetchCards() async throws -> [Card] {
        try await client.get("cards")
    }

    func fetchTransactions() async throws -> [Transaction] {
        try await client.get("transactions")
    }

    func fetchSpending() async throws -> Spending {
        try await client.get("insights/spending")
    }

    // MARK: Actions
    func setCard(_ id: String, locked: Bool) async throws -> Card {
        try await client.send(.patch, "cards/\(id)",
                              body: CardStatusRequest(status: locked ? "locked" : "active"))
    }

    func transfer(_ request: TransferRequest) async throws -> TransferResult {
        try await client.send(.post, "transfers",
                              body: request,
                              headers: ["Idempotency-Key": UUID().uuidString])
    }
}
