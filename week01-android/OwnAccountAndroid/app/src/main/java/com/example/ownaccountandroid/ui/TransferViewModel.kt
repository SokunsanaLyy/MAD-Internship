package com.example.ownaccountandroid.ui

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import com.example.ownaccountandroid.data.ACCOUNT_HOLDER
import com.example.ownaccountandroid.data.Account
import com.example.ownaccountandroid.data.KHR_PER_USD
import com.example.ownaccountandroid.data.ScheduleOption
import com.example.ownaccountandroid.data.TransferSummary
import com.example.ownaccountandroid.data.convert
import com.example.ownaccountandroid.data.formatNumber
import com.example.ownaccountandroid.data.roundDown
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import kotlin.random.Random

// MARK: - TransferViewModel
// ONE shared "brain" for the whole transfer flow.
//
// Why a ViewModel?
//  • Every screen (Form, Verify, Success) needs the same data. Keeping it here means the
//    Verify screen shows exactly what the Form screen entered — no passing values by hand.
//  • A ViewModel survives screen rotation, so the user doesn't lose what they typed.
//
// Each property uses `mutableStateOf`, so any screen that reads it redraws automatically
// when it changes. `private set` means only the ViewModel can change it — screens must
// call a function (e.g. selectFrom), which keeps all the rules in one place.
class TransferViewModel : ViewModel() {

    // MARK: Accounts (balances change after each transfer)
    var accounts by mutableStateOf(Account.samples)
        private set

    // We store the selected accounts' IDs, then look them up in `accounts`.
    // That way the form always shows the LATEST balance after a transfer.
    private var fromId by mutableStateOf<String?>(Account.samples.first().id)
    private var toId by mutableStateOf<String?>(null)

    val fromAccount: Account? get() = accounts.find { it.id == fromId }
    val toAccount: Account? get() = accounts.find { it.id == toId }

    // MARK: Form fields
    var amountText by mutableStateOf("")
        private set
    var hasPurpose by mutableStateOf(false)
        private set
    var purpose by mutableStateOf("")
        private set
    var isScheduled by mutableStateOf(false)
        private set
    var scheduleOption by mutableStateOf(ScheduleOption.Tomorrow)
        private set

    // The receipt of the last confirmed transfer (shown on the Success screen).
    var lastReceipt by mutableStateOf<TransferSummary?>(null)
        private set

    // MARK: - Derived values (calculated, never stored)

    val amount: Double? get() = amountText.toDoubleOrNull()

    // How much the To account receives, in its own currency.
    val creditAmount: Double?
        get() {
            val from = fromAccount ?: return null
            val to = toAccount ?: return null
            val value = amount ?: return null
            return roundDown(convert(value, from.currency, to.currency), to.currency)
        }

    // The first problem found, or null when the form is ready.
    // The Form screen shows this message and disables "Ok" until it's null.
    val validationMessage: String?
        get() {
            val from = fromAccount
            val to = toAccount
            val value = amount
            return when {
                from == null -> "Choose the account to transfer from"
                to == null -> "Choose the account to transfer to"
                from.id == to.id -> "Choose two different accounts"
                value == null || value <= 0.0 -> "Enter an amount"
                value > from.balance -> "Amount is more than your available balance"
                (creditAmount ?: 0.0) <= 0.0 -> "Amount is too small to convert"
                hasPurpose && purpose.isBlank() -> "Enter a purpose, or turn Purpose off"
                else -> null
            }
        }

    val canContinue: Boolean get() = validationMessage == null

    // MARK: - Actions called by the screens

    // Called when the user opens "Own Accounts" from the menu: start with a clean form.
    fun startNew() {
        fromId = accounts.first().id
        toId = null
        amountText = ""
        hasPurpose = false
        purpose = ""
        isScheduled = false
        scheduleOption = ScheduleOption.Tomorrow
    }

    fun selectFrom(account: Account) {
        fromId = account.id
        if (toId == account.id) toId = null   // can't send to the same account
    }

    fun selectTo(account: Account) {
        toId = account.id
    }

    // Only accept numbers with at most one "." and two decimals, e.g. "12" or "12.50".
    fun onAmountChange(text: String) {
        if (text.isEmpty() || Regex("""^\d{0,12}(\.\d{0,2})?$""").matches(text)) {
            amountText = text
        }
    }

    fun onPurposeEnabledChange(enabled: Boolean) {
        hasPurpose = enabled
        if (!enabled) purpose = ""
    }

    fun onPurposeChange(text: String) {
        purpose = text.take(60)
    }

    fun onScheduledChange(enabled: Boolean) {
        isScheduled = enabled
    }

    fun onScheduleOptionChange(option: ScheduleOption) {
        scheduleOption = option
    }

    // Builds the summary shown on the Verify screen (no reference number yet).
    fun buildSummary(reference: String = "—"): TransferSummary? {
        if (!canContinue) return null
        val from = fromAccount ?: return null
        val to = toAccount ?: return null
        val value = amount ?: return null
        return TransferSummary(
            name = ACCOUNT_HOLDER,
            fromAccount = from.number,
            fromCurrency = from.currency,
            toAccount = to.number,
            toCurrency = to.currency,
            amount = creditAmount ?: 0.0,
            debitAmount = -value,
            exchangeRate = if (from.currency != to.currency) "1 USD = ${formatNumber(KHR_PER_USD, "KHR")} KHR" else null,
            reference = reference,
            purpose = purpose.takeIf { hasPurpose && it.isNotBlank() },
            scheduledFor = if (isScheduled) scheduledDateText() else null
        )
    }

    // Called by "Confirm": creates the receipt and, for an immediate transfer, moves the money.
    fun confirm() {
        val receipt = buildSummary(reference = newReference()) ?: return
        val from = fromAccount ?: return
        val to = toAccount ?: return

        if (!receipt.isScheduled) {
            val debit = -receipt.debitAmount
            accounts = accounts.map { account ->
                when (account.id) {
                    from.id -> account.copy(balance = account.balance - debit)
                    to.id -> account.copy(balance = account.balance + receipt.amount)
                    else -> account
                }
            }
        }
        lastReceipt = receipt
    }

    // "Repeat" (and "Set Schedule") on the Success screen: same accounts and amount again.
    fun repeatLast(scheduled: Boolean) {
        isScheduled = scheduled
    }

    // MARK: - Helpers

    private fun scheduledDateText(): String {
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, scheduleOption.days)
        return SimpleDateFormat("d MMM yyyy", Locale.getDefault()).format(calendar.time)
    }

    // 11-digit sample reference number, e.g. "62680002218".
    private fun newReference(): String =
        (1..11).joinToString("") { Random.nextInt(0, 10).toString() }
}
