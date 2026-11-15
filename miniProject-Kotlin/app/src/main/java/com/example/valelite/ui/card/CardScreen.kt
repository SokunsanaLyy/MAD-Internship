package com.example.valelite.ui.card

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
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
import com.example.valelite.data.api.userMessage
import com.example.valelite.data.repo.BankRepository
import com.example.valelite.ui.Format
import com.example.valelite.ui.theme.ValeInk
import com.example.valelite.ui.theme.ValeLime
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class CardViewModel(private val bank: BankRepository) : ViewModel() {

    val card = bank.card                    // shared: Home's "Card locked" chip updates too

    private val _isSaving = MutableStateFlow(false)
    val isSaving: StateFlow<Boolean> = _isSaving.asStateFlow()

    private val _error = MutableStateFlow<String?>(null)
    val error: StateFlow<String?> = _error.asStateFlow()

    fun setLocked(locked: Boolean) {
        viewModelScope.launch {
            _isSaving.value = true
            _error.value = null
            try {
                bank.setCardLocked(locked)
            } catch (e: Exception) {
                _error.value = e.userMessage()
            }
            _isSaving.value = false
        }
    }
}

// ---------------------------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------------------------

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CardScreen(
    onBack: () -> Unit,
    vm: CardViewModel = viewModel { CardViewModel(AppGraph.bank) }
) {
    val card by vm.card.collectAsStateWithLifecycle()
    val isSaving by vm.isSaving.collectAsStateWithLifecycle()
    val error by vm.error.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Card") },
                navigationIcon = { TextButton(onClick = onBack) { Text("Back") } }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier.padding(padding).padding(16.dp).fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            val current = card
            if (current == null) {
                Text("No card found.", color = MaterialTheme.colorScheme.onSurfaceVariant)
                return@Column
            }

            // The debit card
            Column(
                Modifier
                    .fillMaxWidth()
                    .height(190.dp)
                    .background(ValeInk, RoundedCornerShape(24.dp))
                    .padding(20.dp)
            ) {
                Text("Vale debit", color = ValeLime)
                Spacer(Modifier.weight(1f))
                Text(Format.masked(current.last4), color = Color.White, style = MaterialTheme.typography.headlineSmall)
                Spacer(Modifier.height(8.dp))
                Row {
                    Text(current.holderName, color = Color(0xFFA9BBB0), modifier = Modifier.weight(1f))
                    Text(
                        if (current.isLocked) "Locked" else "Active",
                        color = if (current.isLocked) Color(0xFFFF6F61) else ValeLime
                    )
                }
            }

            // Lock switch
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column(Modifier.weight(1f)) {
                    Text("Lock card", style = MaterialTheme.typography.titleMedium)
                    Text(
                        "Stops new card payments until you unlock it",
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                Switch(
                    checked = current.isLocked,
                    onCheckedChange = vm::setLocked,
                    enabled = !isSaving
                )
            }

            error?.let { Text(it, color = MaterialTheme.colorScheme.error) }
        }
    }
}
