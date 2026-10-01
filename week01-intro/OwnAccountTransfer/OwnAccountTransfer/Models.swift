import SwiftUI

// MARK: Account
// The data behind every account row and dropdown.
// Identifiable lets SwiftUI's ForEach tell rows apart.
struct Account: Identifiable, Hashable {
    let id = UUID()
    let number: String
    let currency: String   // "USD" or "KHR"
    let type: String       // "Wallet" or "Savings"
    let balance: Double

    // 58490.25 -> "58,490.25" (USD) and 1689976 -> "1,689,976" (KHR, no decimals)
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let decimals = currency == "USD" ? 2 : 0
        formatter.minimumFractionDigits = decimals
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: balance)) ?? "\(balance)"
    }

    // KHR shows in gold, USD in navy — matches the mock-ups.
    var currencyColor: Color { currency == "KHR" ? .gold : .brandNavy }
}

extension Account {
    static let samples: [Account] = [
        Account(number: "015 555 555",       currency: "KHR", type: "Wallet",  balance: 1_689_976),
        Account(number: "015 555 555",       currency: "USD", type: "Wallet",  balance: 58_490.25),
        Account(number: "0001-06198446-16",   currency: "USD", type: "Savings", balance: 9_832.34),
        Account(number: "0001-06198446-17",   currency: "KHR", type: "Savings", balance: 19_924_440)
    ]
}

// MARK: Transfer summary
// Everything the Verify and Success screens display, in one struct,
// so both screens read from the same data.
struct TransferSummary {
    let name: String
    let fromAccount: String
    let fromCurrency: String
    let toAccount: String
    let toCurrency: String
    let amount: Double
    let debitAmount: Double
    let exchangeRate: String
    let reference: String

    var amountText: String { String(format: "%.2f $", amount) }          // "0.02 $"
    var debitText: String  { "\(Int(debitAmount)) \(fromCurrency)" }      // "-100 KHR"

    static let sample = TransferSummary(
        name: "Sokunsana Ly",
        fromAccount: "015 555 555", fromCurrency: "KHR",
        toAccount: "015 555 555",   toCurrency: "USD",
        amount: 0.02, debitAmount: -100,
        exchangeRate: "1 USD = 4,113 KHR",
        reference: "62680002218"
    )
}
