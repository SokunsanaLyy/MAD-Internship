package com.example.valelite.ui.home

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.valelite.AppGraph
import com.example.valelite.data.api.Account
import com.example.valelite.data.api.Transaction
import com.example.valelite.data.api.userMessage
import com.example.valelite.data.repo.AuthRepository
import com.example.valelite.data.repo.BankRepository
import com.example.valelite.ui.Format
import com.example.valelite.ui.theme.ValeInk
import com.example.valelite.ui.theme.ValeLime
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class HomeViewModel(
    private val bank: BankRepository,
    private val auth: AuthRepository
) : ViewModel() {

    val accounts = bank.accounts            // shared: updates when Transfer changes balances
    val transactions = bank.transactions
    val card = bank.card

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    init { refresh() }

    fun refresh() {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            try {
                bank.loadAll()
            } catch (e: Exception) {
                _error.value = e.userMessage()
            }
            _isLoading.value = false
        }
    }

    fun logout() {
        viewModelScope.launch { auth.logout() }      // AppNavHost goes back to Login
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onTransfer: () -> Unit,
    onCard: () -> Unit,
    vm: HomeViewModel = viewModel { HomeViewModel(AppGraph.bank, AppGraph.auth) }
) {
    val accounts by vm.accounts.collectAsStateWithLifecycle()
    val transactions by vm.transactions.collectAsStateWithLifecycle()
    val card by vm.card.collectAsStateWithLifecycle()
    val isLoading by vm.isLoading.collectAsStateWithLifecycle()
    val error by vm.error.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Vale") },
                actions = { TextButton(onClick = vm::logout) { Text("Log out") } }
            )
        }
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = isLoading,
            onRefresh = vm::refresh,
            modifier = Modifier.padding(padding).fillMaxSize()
        ) {
            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                contentPadding = PaddingValues(16.dp)
            ) {
                error?.let { message ->
                    item { Text(message, color = MaterialTheme.colorScheme.error) }
                }
                items(accounts, key = { it.id }) { account ->
                    BalanceCard(account, showLocked = account.id == "acc_chk" && card?.isLocked == true)
                }
                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        Button(onClick = onTransfer, modifier = Modifier.weight(1f)) { Text("Transfer") }
                        OutlinedButton(onClick = onCard, modifier = Modifier.weight(1f)) { Text("Card") }
                    }
                }
                item {
                    Spacer(Modifier.height(8.dp))
                    Text("Recent activity", style = MaterialTheme.typography.titleMedium)
                }
                items(transactions, key = { it.id }) { TransactionRow(it) }
            }
        }
    }
}

@Composable
private fun BalanceCard(account: Account, showLocked: Boolean) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(ValeInk, RoundedCornerShape(24.dp))
            .padding(20.dp)
    ) {
        Text(account.name, color = Color(0xFFA9BBB0))
        Spacer(Modifier.height(8.dp))
        Text(Format.money(account.balance), color = Color.White, style = MaterialTheme.typography.headlineLarge)
        Spacer(Modifier.height(12.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text("Available balance", color = Color(0xFFA9BBB0), modifier = Modifier.weight(1f))
            if (showLocked) {
                Text(
                    " Card locked ", color = ValeInk,
                    modifier = Modifier.background(ValeLime, RoundedCornerShape(10.dp)).padding(horizontal = 6.dp)
                )
                Spacer(Modifier.width(8.dp))
            }
            Text(Format.masked(account.last4), color = Color(0xFFA9BBB0))
        }
    }
}

@Composable
private fun TransactionRow(transaction: Transaction) {
    Column {
        Row(Modifier.fillMaxWidth().padding(vertical = 8.dp), verticalAlignment = Alignment.CenterVertically) {
            Column(Modifier.weight(1f)) {
                Text(transaction.title, style = MaterialTheme.typography.bodyLarge)
                Text(
                    "${transaction.category} · ${Format.date(transaction.date)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Text(
                Format.signedMoney(transaction.amount),
                color = if (transaction.amount >= 0) MaterialTheme.colorScheme.tertiary else MaterialTheme.colorScheme.onSurface
            )
        }
        HorizontalDivider(color = MaterialTheme.colorScheme.outline)
    }
}
