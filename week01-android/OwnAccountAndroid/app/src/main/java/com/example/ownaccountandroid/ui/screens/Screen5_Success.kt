package com.example.ownaccountandroid.ui.screens

import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalanceWallet
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Share
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ownaccountandroid.data.Account
import com.example.ownaccountandroid.data.TransferSummary
import com.example.ownaccountandroid.ui.AppColors
import com.example.ownaccountandroid.ui.DashedLine
import com.example.ownaccountandroid.ui.InfoRow
import com.example.ownaccountandroid.ui.InitialsAvatar
import com.example.ownaccountandroid.ui.OwnAccountTheme
import com.example.ownaccountandroid.ui.SkyBackground

// SCREEN 5 — Success receipt
// Layout: bank name → check badge overlapping a receipt card → "Set Schedule" pill → action bar.
//
// Navigation buttons (Home, Repeat, Set Schedule) are callbacks handled by AppNavHost.
// Share and Accounts are handled right here, because they don't leave the screen.

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SuccessScreen(
    summary: TransferSummary,
    accounts: List<Account> = Account.samples,
    onHome: () -> Unit = {},
    onRepeat: () -> Unit = {},
    onSetSchedule: () -> Unit = {}
) {
    val context = LocalContext.current
    var isExpanded by remember { mutableStateOf(true) }      // chevron shows/hides the detail rows
    var showAccounts by remember { mutableStateOf(false) }   // "Accounts" bottom sheet

    // Opens Android's share sheet (Messages, Email, Telegram…) with a text receipt.
    val shareReceipt = {
        val sendIntent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_SUBJECT, "Transfer receipt ${summary.reference}")
            putExtra(Intent.EXTRA_TEXT, summary.shareText())
        }
        context.startActivity(Intent.createChooser(sendIntent, "Share receipt"))
    }

    Box(Modifier.fillMaxSize()) {
        SkyBackground()

        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding()
        ) {
            // Placeholder — replace with Image(painterResource(R.drawable.your_logo), …).
            Text("My Bank", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color.White, modifier = Modifier.padding(top = 8.dp))

            // The receipt scrolls if the details are long; the buttons below stay in place.
            Box(
                contentAlignment = Alignment.TopCenter,
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(start = 20.dp, end = 20.dp, top = 12.dp, bottom = 12.dp)
            ) {
                ReceiptCard(
                    summary = summary,
                    isExpanded = isExpanded,
                    onToggle = { isExpanded = !isExpanded },
                    modifier = Modifier.padding(top = 34.dp)
                )
                SuccessBadge()
            }

            // "Set Schedule" pill — repeats this transfer as a scheduled one.
            if (!summary.isScheduled) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp),
                    modifier = Modifier
                        .padding(bottom = 10.dp)
                        .clip(RoundedCornerShape(50))
                        .background(Color.White)
                        .clickable(onClick = onSetSchedule)
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Icon(Icons.Filled.CalendarMonth, contentDescription = null, tint = AppColors.BrandNavy, modifier = Modifier.size(16.dp))
                    Text("Set Schedule", fontSize = 12.sp, fontWeight = FontWeight.Medium, color = AppColors.BrandNavy)
                }
            }

            ActionBar(
                items = listOf(
                    ActionItem(Icons.Outlined.Home, "Home", onHome),
                    ActionItem(Icons.Filled.Refresh, "Repeat", onRepeat),
                    ActionItem(Icons.Filled.AccountBalanceWallet, "Accounts") { showAccounts = true },
                    ActionItem(Icons.Filled.Share, "Share", shareReceipt)
                ),
                modifier = Modifier.padding(bottom = 8.dp)
            )
        }

        // "Accounts" shows the updated balances, read-only.
        if (showAccounts) {
            ModalBottomSheet(
                onDismissRequest = { showAccounts = false },
                sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
                shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp),
                containerColor = AppColors.Surface,
                dragHandle = null
            ) {
                SelectAccountSheet(title = "My Accounts", accounts = accounts)
            }
        }
    }
}

@Composable
private fun ReceiptCard(
    summary: TransferSummary,
    isExpanded: Boolean,
    onToggle: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(14.dp),
        modifier = modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(Color.White)
            .padding(16.dp)
    ) {
        Text(
            if (summary.isScheduled) "Scheduled" else "Success",
            fontSize = 17.sp, fontWeight = FontWeight.SemiBold, color = AppColors.BrandNavy,
            modifier = Modifier.padding(top = 38.dp)   // leaves room under the badge
        )

        // "Transferred to" box
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(10.dp))
                .background(AppColors.Surface)
                .padding(12.dp)
        ) {
            InitialsAvatar(summary.name)
            Column {
                Text(
                    if (summary.isScheduled) "Will transfer to" else "Transferred to",
                    fontSize = 11.sp, color = AppColors.TextSecondary
                )
                Text(summary.name, fontSize = 15.sp, fontWeight = FontWeight.Bold)
                Text(summary.amountText, fontSize = 20.sp, fontWeight = FontWeight.Bold, color = AppColors.DebitRed)
            }
        }

        DashedLine()

        // Details (collapsible)
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                InfoRow("From Account", summary.name, modifier = Modifier.weight(1f))
                IconButton(onClick = onToggle, modifier = Modifier.size(24.dp)) {
                    Icon(
                        if (isExpanded) Icons.Filled.KeyboardArrowUp else Icons.Filled.KeyboardArrowDown,
                        contentDescription = if (isExpanded) "Hide details" else "Show details",
                        tint = AppColors.Gold
                    )
                }
            }

            if (isExpanded) {
                InfoRow("Account No.", "${summary.fromAccount} (${summary.fromCurrency})")
                InfoRow("Debit Amount", summary.debitText, valueColor = AppColors.DebitRed)
                HorizontalDivider(color = AppColors.FieldBorder)
                summary.exchangeRate?.let { InfoRow("Exchange Rate", it) }
                InfoRow("To Account", summary.name)
                InfoRow("Account No.", "${summary.toAccount} (${summary.toCurrency})")
                summary.purpose?.let { InfoRow("Purpose", it) }
                summary.scheduledFor?.let { InfoRow("Transfer Date", it) }
                HorizontalDivider(color = AppColors.FieldBorder)
                InfoRow("Reference No.", summary.reference)
            }
        }
    }
}

// Navy circle with a gold tick and a white ring.
@Composable
fun SuccessBadge() {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(64.dp)
            .clip(CircleShape)
            .background(AppColors.BrandNavy)
            .border(4.dp, Color.White, CircleShape)
    ) {
        Icon(Icons.Filled.Check, contentDescription = "Success", tint = AppColors.Gold, modifier = Modifier.size(32.dp))
    }
}

// One button in the bottom bar: icon, label and what happens on tap.
data class ActionItem(val icon: ImageVector, val title: String, val onClick: () -> Unit)

@Composable
fun ActionBar(items: List<ActionItem>, modifier: Modifier = Modifier) {
    Row(
        modifier = modifier
            .padding(horizontal = 20.dp)
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(Color.White.copy(alpha = 0.92f))
            .padding(vertical = 4.dp)
    ) {
        items.forEach { item ->
            TextButton(onClick = item.onClick, modifier = Modifier.weight(1f)) {   // four equal-width slots
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(item.icon, contentDescription = null, tint = AppColors.BrandNavy, modifier = Modifier.size(20.dp))
                    Text(item.title, fontSize = 11.sp, color = AppColors.BrandNavy)
                }
            }
        }
    }
}

@Preview(showSystemUi = true)
@Composable
private fun SuccessPreview() = OwnAccountTheme { SuccessScreen(TransferSummary.sample) }
