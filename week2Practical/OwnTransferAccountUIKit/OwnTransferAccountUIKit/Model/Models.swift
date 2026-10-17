import UIKit

// MARK: - Constants
// Sample values. In a real app these would come from the bank's server.
let accountHolderName = "Sokunsana Ly"
let khrPerUSD: Double = 4113            // 1 USD = 4,113 KHR

// MARK: - Money helpers
enum Money {

    /// USD shows 2 decimals ("58,490.25"), KHR shows none ("1,689,976").
    static func formatNumber(_ value: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US")      // "," for thousands on every phone
        let decimals = currency == "USD" ? 2 : 0
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// "0.02 $" for USD, "100 KHR" for KHR — matches the mock-ups.
    static func formatAmount(_ value: Double, currency: String) -> String {
        currency == "USD" ? "\(formatNumber(value, currency: currency)) $"
                          : "\(formatNumber(value, currency: currency)) KHR"
    }

    /// Converts between KHR and USD using the fixed sample rate.
    static func convert(_ amount: Double, from: String, to: String) -> Double {
        switch (from, to) {
        case ("KHR", "USD"): return amount / khrPerUSD
        case ("USD", "KHR"): return amount * khrPerUSD
        default:             return amount
        }
    }

    /// Banks never round UP in the customer's favour: USD is cut to cents, KHR to whole riel.
    static func roundDown(_ value: Double, currency: String) -> Double {
        currency == "USD" ? (value * 100).rounded(.down) / 100 : value.rounded(.down)
    }
}

// MARK: - Account
struct Account: Equatable {
    let id = UUID()            // unique, so two accounts with the same number are still different
    let number: String
    let currency: String      
    let type: String
    var balance: Double

    var formattedBalance: String { Money.formatNumber(balance, currency: currency) }

    /// KHR shows in gold, USD in navy.
    var currencyColor: UIColor { currency == "KHR" ? .gold : .brandNavy }

    static let samples: [Account] = [
        Account(number: "076 212 4542",     currency: "KHR", type: "Wallet",  balance: 1_689_976),
        Account(number: "076 212 4542",     currency: "USD", type: "Wallet",  balance: 58_490.25),
        Account(number: "0001-06198446-16", currency: "USD", type: "Savings", balance: 9_832.34),
        Account(number: "0001-06198446-17", currency: "KHR", type: "Savings", balance: 19_924_440)
    ]
}

// MARK: - Schedule options
// Shown as a segmented control when "Schedule Transfer" is switched on.
enum ScheduleOption: Int, CaseIterable {
    case tomorrow, nextWeek, nextMonth

    var label: String {
        switch self {
        case .tomorrow:  return "Tomorrow"
        case .nextWeek:  return "In 1 week"
        case .nextMonth: return "In 1 month"
        }
    }

    var days: Int {
        switch self {
        case .tomorrow:  return 1
        case .nextWeek:  return 7
        case .nextMonth: return 30
        }
    }
}

// MARK: - Transfer summary
// Everything the Verify and Success screens display, built from what the user entered.
struct TransferSummary {
    let name: String
    let fromAccount: String
    let fromCurrency: String
    let toAccount: String
    let toCurrency: String
    let amount: Double            // received, in the To account's currency
    let debitAmount: Double       // taken, in the From account's currency (negative)
    let exchangeRate: String?     // nil when both accounts use the same currency
    let reference: String
    let purpose: String?
    let scheduledFor: String?     // e.g. "22 Oct 2026"; nil = sent now

    var amountText: String { Money.formatAmount(amount, currency: toCurrency) }                          // "0.02 $"
    var debitText: String { "-\(Money.formatNumber(-debitAmount, currency: fromCurrency)) \(fromCurrency)" } // "-100 KHR"
    var isScheduled: Bool { scheduledFor != nil }

    /// Plain-text receipt for the Share button.
    func shareText() -> String {
        var lines = [
            isScheduled ? "Transfer scheduled" : "Transfer successful",
            "Amount: \(amountText)",
            "From: \(fromAccount) (\(fromCurrency))",
            "To: \(toAccount) (\(toCurrency))",
            "Debit amount: \(debitText)"
        ]
        if let exchangeRate { lines.append("Exchange rate: \(exchangeRate)") }
        if let purpose { lines.append("Purpose: \(purpose)") }
        if let scheduledFor { lines.append("Scheduled for: \(scheduledFor)") }
        lines.append("Reference No.: \(reference)")
        return lines.joined(separator: "\n")
    }
}
