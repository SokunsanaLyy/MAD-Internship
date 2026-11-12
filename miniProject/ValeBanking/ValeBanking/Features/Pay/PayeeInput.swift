//
//  PayeeInput.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 5/11/2026.
//

import Foundation

// MARK: - PayeeInput

enum PayeeInput {

    static func normalise(_ text: String, method: PayMethod) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if method == .payid && trimmed.contains("@") {
            return trimmed.lowercased()
        }
        return trimmed.filter(\.isNumber)
    }

    static func error(for text: String, method: PayMethod) -> String? {
        let value = normalise(text, method: method)
        switch method {
        case .account:
            return (6...12).contains(value.count) ? nil : "Enter an account number of 6 to 12 digits."
        case .payid:
            if text.contains("@") {
                return value.contains(".") ? nil : "Enter a valid email address."
            }
            return (8...12).contains(value.count) ? nil : "Enter a mobile number or an email address."
        }
    }

    static func title(for method: PayMethod) -> String {
        method == .account ? "Account number" : "Mobile number or email"
    }

    static func placeholder(for method: PayMethod) -> String {
        method == .account ? "6 to 12 digits" : "e.g. 0412 345 678 or name@example.com"
    }
}
