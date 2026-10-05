package com.example.ownaccountandroid.data

import androidx.compose.ui.graphics.Color
import com.example.ownaccountandroid.ui.AppColors
import java.text.DecimalFormat
import java.text.DecimalFormatSymbols
import java.util.Locale
import java.util.UUID

// MARK: - Constants
// Sample values used by the whole app. In a real app these would come from the bank's server.
const val ACCOUNT_HOLDER = "Sokunsana Ly"
const val KHR_PER_USD = 4113.0          // 1 USD = 4,113 KHR

// MARK: - Money helpers
// USD shows 2 decimals ("58,490.25"), KHR shows none ("1,689,976").
// Locale.US keeps "," for thousands and "." for decimals on every phone.
fun formatNumber(value: Double, currency: String): String {
    val pattern = if (currency == "USD") "#,##0.00" else "#,##0"
    return DecimalFormat(pattern, DecimalFormatSymbols(Locale.US)).format(value)
}

// "0.02 $" for USD, "100 KHR" for KHR — matches the mock-ups.
fun formatAmount(value: Double, currency: String): String =
    if (currency == "USD") "${formatNumber(value, currency)} $" else "${formatNumber(value, currency)} KHR"

// Converts an amount between the two currencies using the fixed sample rate.
fun convert(amount: Double, from: String, to: String): Double = when {
    from == to -> amount
    from == "KHR" && to == "USD" -> amount / KHR_PER_USD
    from == "USD" && to == "KHR" -> amount * KHR_PER_USD
    else -> amount
}

// Banks never round money UP in the customer's favour: USD is cut to cents, KHR to whole riel.
fun roundDown(value: Double, currency: String): Double =
    if (currency == "USD") kotlin.math.floor(value * 100) / 100 else kotlin.math.floor(value)

// MARK: - Account
// The data behind every account row and dropdown.
// `data class` gives equals/hashCode/copy for free. `copy` keeps the same id, so an account
// with a new balance is still recognised as the same account.
data class Account(
    val id: String = UUID.randomUUID().toString(),
    val number: String,
    val currency: String,   // "USD" or "KHR"
    val type: String,       // "Wallet" or "Savings"
    val balance: Double
) {
    val formattedBalance: String get() = formatNumber(balance, currency)

    // KHR shows in gold, USD in navy.
    val currencyColor: Color get() = if (currency == "KHR") AppColors.Gold else AppColors.BrandNavy

    companion object {
        val samples = listOf(
            Account(number = "015 555 555",     currency = "KHR", type = "Wallet",  balance = 1_689_976.0),
            Account(number = "015 555 555",     currency = "USD", type = "Wallet",  balance = 58_490.25),
            Account(number = "0001-06198446-16", currency = "USD", type = "Savings", balance = 9_832.34),
            Account(number = "0001-06198446-17", currency = "KHR", type = "Savings", balance = 19_924_440.0)
        )
    }
}

// MARK: - Schedule options
// Shown as chips when "Schedule Transfer" is switched on.
enum class ScheduleOption(val label: String, val days: Int) {
    Tomorrow("Tomorrow", 1),
    NextWeek("In 1 week", 7),
    NextMonth("In 1 month", 30)
}

// MARK: - Transfer summary
// Everything the Verify and Success screens display. The ViewModel builds it from what the
// user entered, so both screens always show the same, real values.
data class TransferSummary(
    val name: String,
    val fromAccount: String,
    val fromCurrency: String,
    val toAccount: String,
    val toCurrency: String,
    val amount: Double,          // amount received, in the To account's currency
    val debitAmount: Double,     // amount taken, in the From account's currency (negative)
    val exchangeRate: String?,   // null when both accounts use the same currency
    val reference: String,
    val purpose: String? = null,
    val scheduledFor: String? = null   // e.g. "12 Oct 2026"; null = sent now
) {
    val amountText: String get() = formatAmount(amount, toCurrency)                           // "0.02 $"
    val debitText: String get() = "-${formatNumber(-debitAmount, fromCurrency)} $fromCurrency" // "-100 KHR"
    val isScheduled: Boolean get() = scheduledFor != null

    // Plain-text receipt used by the Share button.
    fun shareText(): String = buildString {
        appendLine(if (isScheduled) "Transfer scheduled" else "Transfer successful")
        appendLine("Amount: $amountText")
        appendLine("From: $fromAccount ($fromCurrency)")
        appendLine("To: $toAccount ($toCurrency)")
        appendLine("Debit amount: $debitText")
        exchangeRate?.let { appendLine("Exchange rate: $it") }
        purpose?.let { appendLine("Purpose: $it") }
        scheduledFor?.let { appendLine("Scheduled for: $it") }
        append("Reference No.: $reference")
    }

    companion object {
        // Used only by @Preview functions.
        val sample = TransferSummary(
            name = ACCOUNT_HOLDER,
            fromAccount = "015 555 555", fromCurrency = "KHR",
            toAccount = "015 555 555", toCurrency = "USD",
            amount = 0.02, debitAmount = -100.0,
            exchangeRate = "1 USD = 4,113 KHR",
            reference = "62680002218"
        )
    }
}
