//
//  Models.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 30/10/2026.
//

import Foundation

// MARK: - Data from the Vale API

/// GET /me
struct User: Codable {
    let id: String
    let firstName: String
    let fullName: String
    let email: String
    let phoneLast4: String
    let verified: Bool

    var initial: String { String(firstName.prefix(1)).uppercased() }
}

struct Account: Codable {
    let id: String
    let name: String
    let type: String
    let last4: String
    let currency: String
    var balance: Double
    let status: String

    var isSavings: Bool { type == "savings" }
    var symbol: String { isSavings ? "leaf" : "wallet.pass" }
}

struct Card: Codable {
    let id: String
    let holderName: String
    let last4: String
    let kind: String
    var status: String        
    let linkedAccountId: String

    var isLocked: Bool { status == "locked" }
}

struct Transaction: Codable {
    let id: String
    let title: String
    let category: String
    let date: String
    let amount: Double
    let icon: String

    var isIncome: Bool { amount > 0 }

    var symbol: String {
        switch icon {
        case "groceries": return "basket"
        case "food": return "cup.and.saucer"
        case "transfer": return "arrow.up.right"
        case "own-transfer": return "arrow.left.arrow.right"
        case "salary": return "briefcase"
        default: return "dollarsign.circle"
        }
    }
}

struct Spending: Codable {
    let month: String
    let periodLabel: String
    let total: Double
    let changePercent: Int
    let weeks: [Week]
    let categories: [Category]
    let income: Double
    let netCashFlow: Double

    struct Week: Codable {
        let label: String
        let amount: Double
    }

    struct Category: Codable {
        let name: String
        let amount: Double
    }
}

// MARK: - Request and response bodies

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let challengeId: String
    let phoneLast4: String
    let expiresIn: Int
}

struct VerifyRequest: Codable {
    let challengeId: String
    let code: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
}

struct CardStatusRequest: Codable {
    let status: String
}

struct TransferRequest: Codable {
    let fromAccountId: String
    let toAccountId: String
    let amount: Double
    let note: String
}

struct TransferResult: Codable {
    let id: String
    let status: String
    let fromAccountId: String
    let toAccountId: String
    let amount: Double
    let note: String
    let date: String
}

/// Error bodies from the API: { "error": "...", "message": "..." }
struct APIErrorBody: Codable {
    let message: String
}

