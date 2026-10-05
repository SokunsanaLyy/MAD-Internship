package com.example.ownaccountandroid.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ownaccountandroid.data.Account
import com.example.ownaccountandroid.ui.AppColors
import com.example.ownaccountandroid.ui.OwnAccountTheme

// SCREEN 3 — Select Account
// A real Material bottom sheet. It slides up over the form, dims the screen behind it,
// and closes when the user picks an account, taps outside, swipes down or presses Back.

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AccountPickerSheet(
    title: String,
    accounts: List<Account>,
    selectedId: String?,
    onSelect: (Account) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true),
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp),
        containerColor = AppColors.Surface,
        dragHandle = null              // our navy title bar replaces the default handle
    ) {
        SelectAccountSheet(
            title = title,
            accounts = accounts,
            selectedId = selectedId,
            onSelect = onSelect
        )
    }
}

// The sheet's content: navy title bar + one row per account.
// Also reused read-only by the "Accounts" button on the Success screen.
@Composable
fun SelectAccountSheet(
    title: String = "Select Account",
    accounts: List<Account> = Account.samples,
    selectedId: String? = null,
    onSelect: ((Account) -> Unit)? = null      // null = rows are not tappable
) {
    Column(Modifier.fillMaxWidth()) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp)
                .background(Brush.verticalGradient(listOf(AppColors.BrandNavy.copy(alpha = 0.8f), AppColors.BrandNavy)))
        ) {
            Text(title, color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
        }

        accounts.forEach { account ->
            AccountRow(
                account = account,
                isSelected = account.id == selectedId,
                onClick = onSelect?.let { select -> { select(account) } }
            )
            HorizontalDivider(color = AppColors.FieldBorder)
        }
        Spacer(Modifier.height(24.dp))
    }
}

// Two lines: number + currency / type + balance. A tick marks the current choice.
@Composable
fun AccountRow(account: Account, isSelected: Boolean = false, onClick: (() -> Unit)? = null) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .fillMaxWidth()
            .background(if (isSelected) AppColors.BrandNavy.copy(alpha = 0.06f) else Color.Transparent)
            .then(if (onClick != null) Modifier.clickable(onClick = onClick) else Modifier)  // whole row tappable
            .padding(horizontal = 16.dp, vertical = 12.dp)
    ) {
        Column(Modifier.weight(1f)) {
            Row(Modifier.fillMaxWidth()) {
                Text(account.number, fontSize = 15.sp, fontWeight = FontWeight.Medium, color = AppColors.BrandNavy, modifier = Modifier.weight(1f))
                Text(account.currency, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = account.currencyColor)
            }
            Spacer(Modifier.height(6.dp))
            Row(Modifier.fillMaxWidth()) {
                Text(account.type, fontSize = 12.sp, color = AppColors.TextSecondary, modifier = Modifier.weight(1f))
                Text(account.formattedBalance, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = account.currencyColor)
            }
        }
        if (isSelected) {
            Spacer(Modifier.width(12.dp))
            Icon(Icons.Filled.CheckCircle, contentDescription = "Selected", tint = AppColors.Gold, modifier = Modifier.size(20.dp))
        }
    }
}

@Preview(showBackground = true)
@Composable
private fun SelectAccountSheetPreview() = OwnAccountTheme {
    SelectAccountSheet(selectedId = Account.samples.first().id, onSelect = {})
}
