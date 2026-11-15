package com.example.valelite.ui

import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Locale

object Format {

    private val money = NumberFormat.getCurrencyInstance(Locale.US)     // the API's currency is USD

    fun money(amount: Double): String = money.format(amount)

    fun signedMoney(amount: Double): String =
        (if (amount >= 0) "+" else "−") + money.format(kotlin.math.abs(amount))

    fun masked(last4: String): String = "•••• $last4"

    fun date(apiDate: String): String = runCatching {
        val parsed = SimpleDateFormat("yyyy-MM-dd", Locale.US).parse(apiDate)
        SimpleDateFormat("d MMM", Locale.getDefault()).format(parsed!!)
    }.getOrDefault(apiDate)
}
