package com.example.ownaccountandroid.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
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
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.ownaccountandroid.data.Account
import com.example.ownaccountandroid.data.ScheduleOption
import com.example.ownaccountandroid.data.formatAmount
import com.example.ownaccountandroid.ui.AppColors
import com.example.ownaccountandroid.ui.FieldAccessory
import com.example.ownaccountandroid.ui.FloatingLabel
import com.example.ownaccountandroid.ui.HeaderBar
import com.example.ownaccountandroid.ui.OwnAccountTheme
import com.example.ownaccountandroid.ui.PrimaryButton
import com.example.ownaccountandroid.ui.SkyBackground
import com.example.ownaccountandroid.ui.TransferViewModel
import com.example.ownaccountandroid.ui.outlinedBox

// SCREEN 2 — Own Accounts form
// Layout: sky background → header → icon badge → white sheet with fields → flat "Ok" bar.
//
// All form data lives in the shared TransferViewModel. This screen reads it to draw the
// fields and calls ViewModel functions when the user types or taps.

// Which dropdown opened the account picker sheet.
private enum class PickTarget { From, To }

@Composable
fun OwnAccountFormScreen(
    viewModel: TransferViewModel,
    onBack: () -> Unit,
    onContinue: () -> Unit
) {
    // Local UI state: is the account picker open, and for which field?
    // It's only about this screen's appearance, so it lives here, not in the ViewModel.
    var picking by remember { mutableStateOf<PickTarget?>(null) }

    val message = viewModel.validationMessage

    Box(Modifier.fillMaxSize()) {
        SkyBackground()

        Column(
            Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .imePadding()           // moves content up when the keyboard opens
        ) {
            HeaderBar(title = "Transfers", onBack = onBack)

            FeatureBadge(
                icon = Icons.Filled.SwapHoriz,
                title = "Own Accounts",
                modifier = Modifier.align(Alignment.CenterHorizontally).padding(vertical = 16.dp)
            )

            Column(
                verticalArrangement = Arrangement.spacedBy(18.dp),
                modifier = Modifier
                    .weight(1f)
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                    .background(Color.White)
                    .verticalScroll(rememberScrollState())   // scrolls when Purpose/Schedule add rows
                    .padding(20.dp)
            ) {
                AccountDropdown(
                    label = "From Account",
                    account = viewModel.fromAccount,
                    onClick = { picking = PickTarget.From }
                )
                AccountDropdown(
                    label = "To Account",
                    account = viewModel.toAccount,
                    onClick = { picking = PickTarget.To }
                )

                AmountField(
                    amount = viewModel.amountText,
                    currency = viewModel.fromAccount?.currency,
                    onAmountChange = viewModel::onAmountChange
                )

                // Live preview of what the other account receives (only when currencies differ).
                val from = viewModel.fromAccount
                val to = viewModel.toAccount
                val credit = viewModel.creditAmount
                if (from != null && to != null && credit != null && from.currency != to.currency) {
                    Text(
                        "You'll receive about ${formatAmount(credit, to.currency)}",
                        fontSize = 12.sp, color = AppColors.TextSecondary
                    )
                }

                ToggleRow(title = "Purpose", checked = viewModel.hasPurpose, onCheckedChange = viewModel::onPurposeEnabledChange)
                if (viewModel.hasPurpose) {
                    OutlinedTextField(
                        value = viewModel.purpose,
                        onValueChange = viewModel::onPurposeChange,
                        label = { Text("Purpose (e.g. Savings)") },
                        singleLine = true,
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.fillMaxWidth()
                    )
                }

                ToggleRow(title = "Schedule Transfer", checked = viewModel.isScheduled, onCheckedChange = viewModel::onScheduledChange)
                if (viewModel.isScheduled) {
                    ScheduleChips(selected = viewModel.scheduleOption, onSelect = viewModel::onScheduleOptionChange)
                }

                // Tells the user exactly why "Ok" is disabled.
                if (message != null) {
                    Text(
                        message,
                        fontSize = 12.sp,
                        textAlign = TextAlign.Center,
                        color = if (message.startsWith("Amount is more")) AppColors.DebitRed else AppColors.TextSecondary,
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            // Flat bar that runs under the navigation bar. Disabled until the form is valid.
            Box(Modifier.background(AppColors.BrandNavy).navigationBarsPadding()) {
                PrimaryButton(
                    title = "Ok",
                    cornerRadius = 0.dp,
                    enabled = viewModel.canContinue,
                    onClick = onContinue
                )
            }
        }

        // SCREEN 3 — the account picker opens as a bottom sheet over this screen.
        when (picking) {
            PickTarget.From -> AccountPickerSheet(
                title = "Select From Account",
                accounts = viewModel.accounts,
                selectedId = viewModel.fromAccount?.id,
                onSelect = { viewModel.selectFrom(it); picking = null },
                onDismiss = { picking = null }
            )
            PickTarget.To -> AccountPickerSheet(
                title = "Select To Account",
                // You can't transfer into the account you're sending from, so hide it.
                accounts = viewModel.accounts.filter { it.id != viewModel.fromAccount?.id },
                selectedId = viewModel.toAccount?.id,
                onSelect = { viewModel.selectTo(it); picking = null },
                onDismiss = { picking = null }
            )
            null -> Unit
        }
    }
}

// Rounded icon tile with a label underneath.
@Composable
fun FeatureBadge(icon: ImageVector, title: String, modifier: Modifier = Modifier) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = modifier) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(60.dp)
                .clip(RoundedCornerShape(16.dp))
                .background(AppColors.BrandIndigo)
                .border(2.dp, Color.White, RoundedCornerShape(16.dp))
        ) {
            Icon(icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(28.dp))
        }
        Spacer(Modifier.size(8.dp))
        Text(title, fontSize = 12.sp, color = Color.White)
    }
}

// Empty: label shown as placeholder inside the box.
// Filled: label floats on the border, account number + balance on the right.
// The whole box is tappable and opens the account picker.
@Composable
fun AccountDropdown(label: String, account: Account?, onClick: () -> Unit = {}) {
    Box(Modifier.fillMaxWidth()) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(8.dp))
                .clickable(onClick = onClick)
                .outlinedBox()
        ) {
            if (account != null) {
                Spacer(Modifier.weight(1f))
                Column(horizontalAlignment = Alignment.End, modifier = Modifier.padding(end = 8.dp)) {
                    Text(account.number, fontSize = 12.sp, color = AppColors.TextSecondary)
                    Text(
                        "${account.formattedBalance} ${account.currency}",
                        fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = account.currencyColor
                    )
                }
            } else {
                Text(label, fontSize = 15.sp, color = AppColors.TextSecondary, modifier = Modifier.weight(1f))
            }
            FieldAccessory(Icons.Filled.ArrowDropDown)
        }
        if (account != null) FloatingLabel(label)
    }
}

@Composable
fun AmountField(amount: String, currency: String?, onAmountChange: (String) -> Unit) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier.fillMaxWidth().outlinedBox()
    ) {
        Box(Modifier.weight(1f)) {
            if (amount.isEmpty()) {
                Text(
                    if (currency != null) "Amount ($currency)" else "Amount",
                    fontSize = 15.sp, color = AppColors.TextSecondary
                )
            }
            BasicTextField(
                value = amount,
                onValueChange = onAmountChange,
                singleLine = true,
                textStyle = TextStyle(fontSize = 15.sp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),  // number pad
                modifier = Modifier.fillMaxWidth()
            )
        }
        if (amount.isNotEmpty() && currency != null) {
            Text(currency, fontSize = 13.sp, color = AppColors.TextSecondary, modifier = Modifier.padding(end = 8.dp))
        }
        FieldAccessory(Icons.Filled.Info, tint = AppColors.BrandNavy)
    }
}

@Composable
fun ToggleRow(title: String, checked: Boolean, onCheckedChange: (Boolean) -> Unit) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
        Text(title, fontSize = 15.sp, color = AppColors.BrandNavy, modifier = Modifier.weight(1f))
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            colors = SwitchDefaults.colors(checkedTrackColor = AppColors.BrandNavy)
        )
    }
}

// Three chips: Tomorrow / In 1 week / In 1 month. Only one can be selected.
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ScheduleChips(selected: ScheduleOption, onSelect: (ScheduleOption) -> Unit) {
    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        ScheduleOption.values().forEach { option ->
            FilterChip(
                selected = option == selected,
                onClick = { onSelect(option) },
                label = { Text(option.label, fontSize = 12.sp) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = AppColors.BrandNavy,
                    selectedLabelColor = Color.White
                )
            )
        }
    }
}

@Preview(showSystemUi = true)
@Composable
private fun OwnAccountFormPreview() = OwnAccountTheme {
    // viewModel() asks Android for the ViewModel instead of creating it with TransferViewModel().
    OwnAccountFormScreen(viewModel = viewModel(), onBack = {}, onContinue = {})
}