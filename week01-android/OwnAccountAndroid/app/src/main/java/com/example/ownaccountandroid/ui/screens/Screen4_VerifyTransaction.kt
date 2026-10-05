package com.example.ownaccountandroid.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ownaccountandroid.data.TransferSummary
import com.example.ownaccountandroid.ui.AppColors
import com.example.ownaccountandroid.ui.DetailRow
import com.example.ownaccountandroid.ui.HeaderBar
import com.example.ownaccountandroid.ui.InitialsAvatar
import com.example.ownaccountandroid.ui.OwnAccountTheme
import com.example.ownaccountandroid.ui.PrimaryButton
import com.example.ownaccountandroid.ui.SkyBackground
import com.example.ownaccountandroid.ui.card

// SCREEN 4 — Verify transaction
// Layout: header → translucent panel with title + details card → Confirm button at the bottom.
// It only DISPLAYS the summary it is given; Confirm and Back are reported through callbacks.

@Composable
fun VerifyTransactionScreen(
    summary: TransferSummary,
    onBack: () -> Unit = {},
    onConfirm: () -> Unit = {}
) {
    Box(Modifier.fillMaxSize()) {
        SkyBackground()

        Column(Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding()) {
            HeaderBar(title = "Transfers", onBack = onBack)

            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(start = 16.dp, end = 16.dp, top = 40.dp)
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier
                        .clip(RoundedCornerShape(20.dp))
                        .background(Color.White.copy(alpha = 0.4f))
                        .padding(12.dp)
                ) {
                    Text("Please verify transaction", fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppColors.BrandNavy)
                    DetailsCard(summary)
                }
            }

            PrimaryButton(
                title = if (summary.isScheduled) "Confirm Schedule" else "Confirm",
                modifier = Modifier.padding(start = 20.dp, end = 20.dp, top = 12.dp, bottom = 12.dp),
                onClick = onConfirm
            )
        }
    }
}

@Composable
private fun DetailsCard(summary: TransferSummary) {
    Column(
        verticalArrangement = Arrangement.spacedBy(14.dp),
        modifier = Modifier.fillMaxWidth().card()
    ) {
        // Recipient
        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(12.dp)) {
            InitialsAvatar(summary.name)
            Column {
                Text(summary.name, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                Text("${summary.toAccount} (${summary.toCurrency})", fontSize = 12.sp, color = AppColors.TextSecondary)
            }
        }

        DetailRow(label = "Amount") {
            Text(summary.amountText, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = AppColors.Gold)
        }

        HorizontalDivider(color = AppColors.FieldBorder)

        DetailRow(label = "Transfer From") {
            Column {
                Text(summary.name, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                Text("${summary.fromAccount} (${summary.fromCurrency})", fontSize = 12.sp, color = AppColors.TextSecondary)
            }
        }

        HorizontalDivider(color = AppColors.FieldBorder)

        // Optional rows only appear when they apply.
        summary.exchangeRate?.let { rate ->
            DetailRow(label = "Exchange Rate") { Text(rate, fontSize = 12.sp) }
        }
        DetailRow(label = "Debit Amount") {
            Text(summary.debitText, fontSize = 15.sp, fontWeight = FontWeight.Bold)
        }
        summary.purpose?.let { purpose ->
            DetailRow(label = "Purpose") { Text(purpose, fontSize = 12.sp) }
        }
        summary.scheduledFor?.let { date ->
            DetailRow(label = "Transfer Date") { Text(date, fontSize = 12.sp, fontWeight = FontWeight.SemiBold) }
        }
    }
}

@Preview(showSystemUi = true)
@Composable
private fun VerifyTransactionPreview() = OwnAccountTheme { VerifyTransactionScreen(TransferSummary.sample) }
