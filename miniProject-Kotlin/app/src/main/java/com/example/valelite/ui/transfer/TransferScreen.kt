package com.example.valelite.ui.transfer

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.valelite.AppGraph
import com.example.valelite.data.api.Account
import com.example.valelite.data.api.userMessage
import com.example.valelite.data.repo.BankRepository
import com.example.valelite.ui.Format
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class TransferForm(
    val fromChecking: Boolean = true,
    val amountText: String = "",
    val note: String = "",
    val isSending: Boolean = false,
    val serverError: String? = null,
    val done: Boolean = false
)

data class TransferUiState(
    val form: TransferForm,
    val from: Account?,
    val to: Account?,
    val amountError: String?
) {
    val canSend: Boolean
        get() = !form.isSending && from != null && to != null &&
                form.amountText.isNotBlank() && amountError == null
}

class TransferViewModel(private val bank: BankRepository) : ViewModel() {

    private val form = MutableStateFlow(TransferForm())

    val state: StateFlow<TransferUiState> = combine(form, bank.accounts) { f, accounts ->
        val checking = accounts.firstOrNull { it.type == "checking" }
        val savings = accounts.firstOrNull { it.type == "savings" }
        val from = if (f.fromChecking) checking else savings
        val to = if (f.fromChecking) savings else checking
        TransferUiState(f, from, to, amountError(f.amountText, from))
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), TransferUiState(TransferForm(), null, null, null))

    fun swap() = form.update { it.copy(fromChecking = !it.fromChecking, serverError = null) }
    fun onAmountChange(value: String) = form.update { it.copy(amountText = value, serverError = null) }
    fun onNoteChange(value: String) = form.update { it.copy(note = value.take(30), serverError = null) }

    fun send() {
        val current = state.value
        val from = current.from ?: return
        val to = current.to ?: return
        val amount = current.form.amountText.toDoubleOrNull() ?: return
        if (!current.canSend) return

        form.update { it.copy(isSending = true, serverError = null) }
        viewModelScope.launch {
            try {
                bank.transfer(from, to, amount, current.form.note.trim())
                form.update { it.copy(isSending = false, done = true) }
            } catch (e: Exception) {
                // e.g. Mockoon's 422 when the note is "decline"
                form.update { it.copy(isSending = false, serverError = e.userMessage()) }
            }
        }
    }

    private fun amountError(text: String, from: Account?): String? {
        if (text.isBlank()) return null
        val amount = text.toDoubleOrNull() ?: return "Enter a valid amount."
        if (amount <= 0) return "Enter an amount above $0."
        if (text.substringAfter('.', "").length > 2) return "Use at most 2 decimal places."
        if (from != null && amount > from.balance) return "That's more than the ${Format.money(from.balance)} available."
        return null
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TransferScreen(
    onDone: () -> Unit,
    vm: TransferViewModel = viewModel { TransferViewModel(AppGraph.bank) }
) {
    val state by vm.state.collectAsStateWithLifecycle()

    LaunchedEffect(state.form.done) { if (state.form.done) onDone() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Transfer") },
                navigationIcon = { TextButton(onClick = onDone) { Text("Back") } }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.padding(padding).padding(16.dp).fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text("From", color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text(state.from?.name ?: "—", style = MaterialTheme.typography.titleMedium)
                    Text(state.from?.let { Format.money(it.balance) } ?: "", color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                TextButton(onClick = vm::swap) { Text("⇄ Swap") }
                Column(Modifier.weight(1f), horizontalAlignment = Alignment.End) {
                    Text("To", color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text(state.to?.name ?: "—", style = MaterialTheme.typography.titleMedium)
                }
            }

            OutlinedTextField(
                value = state.form.amountText, onValueChange = vm::onAmountChange,
                label = { Text("Amount") }, prefix = { Text("$") }, singleLine = true,
                isError = state.amountError != null,
                supportingText = { state.amountError?.let { Text(it) } },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Decimal),
                modifier = Modifier.fillMaxWidth()
            )
            OutlinedTextField(
                value = state.form.note, onValueChange = vm::onNoteChange,
                label = { Text("Note (optional)") }, singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )

            state.form.serverError?.let { Text(it, color = MaterialTheme.colorScheme.error) }

            Spacer(Modifier.height(8.dp))
            Button(
                onClick = vm::send,
                enabled = state.canSend,
                modifier = Modifier.fillMaxWidth().height(52.dp)
            ) {
                if (state.form.isSending) CircularProgressIndicator(Modifier.size(20.dp), strokeWidth = 2.dp)
                else Text("Transfer")
            }
        }
    }
}
