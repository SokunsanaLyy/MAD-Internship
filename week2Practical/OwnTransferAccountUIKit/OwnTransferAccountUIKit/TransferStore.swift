import Foundation

// MARK: - TransferStore
// ONE shared "brain" for the whole transfer flow (the iOS version of the Android ViewModel).
//
//  • SceneDelegate creates it once and passes the SAME instance to every screen, so the
//    Verify screen shows exactly what the Form screen entered.
//  • `private(set)` means screens can READ values but must call a function to CHANGE them.
//    That keeps every rule (validation, conversion, balances) in this one file.
//  • It's a `class` (not a struct) so every screen shares the same object, not a copy.
final class TransferStore {

    // MARK: State
    private(set) var accounts: [Account] = Account.samples
    private var fromID: UUID?
    private var toID: UUID?

    private(set) var amountText = ""
    private(set) var hasPurpose = false
    private(set) var purpose = ""
    private(set) var isScheduled = false
    private(set) var scheduleOption: ScheduleOption = .tomorrow

    init() {
        fromID = accounts.first?.id
    }

    // Looked up by ID, so the form always shows the LATEST balance after a transfer.
    var fromAccount: Account? { accounts.first { $0.id == fromID } }
    var toAccount: Account? { accounts.first { $0.id == toID } }

    // MARK: Derived values (calculated, never stored)

    var amount: Double? { Double(amountText) }

    /// What the To account receives, in its own currency.
    var creditAmount: Double? {
        guard let from = fromAccount, let to = toAccount, let value = amount else { return nil }
        return Money.roundDown(Money.convert(value, from: from.currency, to: to.currency), currency: to.currency)
    }

    /// The first problem found, or nil when the form is ready.
    /// The form shows this message and disables "Ok" until it's nil.
    var validationMessage: String? {
        guard let from = fromAccount else { return "Choose the account to transfer from" }
        guard let to = toAccount else { return "Choose the account to transfer to" }
        if from.id == to.id { return "Choose two different accounts" }
        guard let value = amount, value > 0 else { return "Enter an amount" }
        if value > from.balance { return "Amount is more than your available balance" }
        if (creditAmount ?? 0) <= 0 { return "Amount is too small to convert" }
        if hasPurpose && purpose.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Enter a purpose, or turn Purpose off"
        }
        return nil
    }

    var canContinue: Bool { validationMessage == nil }

    // MARK: Actions called by the screens

    /// Menu → Own Accounts: start with a clean form.
    func startNew() {
        fromID = accounts.first?.id
        toID = nil
        amountText = ""
        hasPurpose = false
        purpose = ""
        isScheduled = false
        scheduleOption = .tomorrow
    }

    func selectFrom(_ account: Account) {
        fromID = account.id
        if toID == account.id { toID = nil }      // can't send to the same account
    }

    func selectTo(_ account: Account) {
        toID = account.id
    }

    /// True for text like "", "12", "12.5", "12.50". Used to block letters and a 3rd decimal while typing.
    func isAllowedAmountInput(_ text: String) -> Bool {
        text.range(of: #"^\d{0,12}(\.\d{0,2})?$"#, options: .regularExpression) != nil
    }

    func setAmountText(_ text: String) {
        if isAllowedAmountInput(text) { amountText = text }
    }

    func setPurposeEnabled(_ enabled: Bool) {
        hasPurpose = enabled
        if !enabled { purpose = "" }
    }

    func setPurpose(_ text: String) {
        purpose = String(text.prefix(60))
    }

    func setScheduled(_ enabled: Bool) {
        isScheduled = enabled
    }

    func setScheduleOption(_ option: ScheduleOption) {
        scheduleOption = option
    }

    /// Builds the summary shown on Verify (no reference number yet).
    func buildSummary(reference: String = "—") -> TransferSummary? {
        guard canContinue, let from = fromAccount, let to = toAccount, let value = amount else { return nil }
        return TransferSummary(
            name: accountHolderName,
            fromAccount: from.number,
            fromCurrency: from.currency,
            toAccount: to.number,
            toCurrency: to.currency,
            amount: creditAmount ?? 0,
            debitAmount: -value,
            exchangeRate: from.currency != to.currency
                ? "1 USD = \(Money.formatNumber(khrPerUSD, currency: "KHR")) KHR" : nil,
            reference: reference,
            purpose: hasPurpose && !purpose.isEmpty ? purpose : nil,
            scheduledFor: isScheduled ? scheduledDateText() : nil
        )
    }

    /// "Confirm": creates the receipt and, for an immediate transfer, moves the money.
    func confirm() -> TransferSummary? {
        guard let receipt = buildSummary(reference: newReference()),
              let fromIndex = accounts.firstIndex(where: { $0.id == fromID }),
              let toIndex = accounts.firstIndex(where: { $0.id == toID }) else { return nil }

        if !receipt.isScheduled {
            accounts[fromIndex].balance -= -receipt.debitAmount
            accounts[toIndex].balance += receipt.amount
        }
        return receipt
    }

    /// "Repeat" / "Set Schedule" on the receipt: same accounts and amount again.
    func repeatLast(scheduled: Bool) {
        isScheduled = scheduled
    }

    // MARK: Helpers

    private func scheduledDateText() -> String {
        let date = Calendar.current.date(byAdding: .day, value: scheduleOption.days, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }

    /// 11-digit sample reference number, e.g. "62680002218".
    private func newReference() -> String {
        (0..<11).map { _ in String(Int.random(in: 0...9)) }.joined()
    }
}
