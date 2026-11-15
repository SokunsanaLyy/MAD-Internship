package com.example.valelite.ui.login

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.valelite.AppGraph
import com.example.valelite.data.api.userMessage
import com.example.valelite.data.repo.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class LoginUiState(
    val step: Step = Step.Credentials,
    val email: String = "",
    val password: String = "",
    val code: String = "",
    val phoneLast4: String = "",
    val isLoading: Boolean = false,
    val error: String? = null
) {
    enum class Step { Credentials, Code }

    val canContinue: Boolean
        get() = !isLoading && when (step) {
            Step.Credentials -> email.contains("@") && password.isNotBlank()
            Step.Code -> code.length == 6
        }
}

class LoginViewModel(private val auth: AuthRepository) : ViewModel() {

    private val _state = MutableStateFlow(LoginUiState())
    val state: StateFlow<LoginUiState> = _state.asStateFlow()

    fun onEmailChange(value: String) = _state.update { it.copy(email = value, error = null) }
    fun onPasswordChange(value: String) = _state.update { it.copy(password = value, error = null) }
    fun onCodeChange(value: String) =
        _state.update { it.copy(code = value.filter(Char::isDigit).take(6), error = null) }

    fun backToCredentials() = _state.update { it.copy(step = LoginUiState.Step.Credentials, code = "", error = null) }

    fun submit() {
        val current = _state.value
        if (!current.canContinue) return
        _state.update { it.copy(isLoading = true, error = null) }

        viewModelScope.launch {
            try {
                when (current.step) {
                    LoginUiState.Step.Credentials -> {
                        val last4 = auth.login(current.email, current.password)
                        _state.update { it.copy(step = LoginUiState.Step.Code, phoneLast4 = last4, isLoading = false) }
                    }
                    LoginUiState.Step.Code -> {
                        auth.verify(current.code)
                        // SessionRepository now has a token → AppNavHost switches to Home by itself.
                        // Reset the form so the next log out starts on a clean Login screen.
                        _state.value = LoginUiState()
                    }
                }
            } catch (e: Exception) {
                _state.update { it.copy(isLoading = false, error = e.userMessage(), code = "") }
            }
        }
    }
}

@Composable
fun LoginScreen(vm: LoginViewModel = viewModel { LoginViewModel(AppGraph.auth) }) {
    val state by vm.state.collectAsStateWithLifecycle()

    Column(
        modifier = Modifier.fillMaxSize().padding(24.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text("Vale", style = MaterialTheme.typography.displaySmall)
        Spacer(Modifier.height(8.dp))

        when (state.step) {
            LoginUiState.Step.Credentials -> {
                Text("Sign in to your account", color = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.height(24.dp))
                OutlinedTextField(
                    value = state.email, onValueChange = vm::onEmailChange,
                    label = { Text("Email") }, singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                    modifier = Modifier.fillMaxWidth()
                )
                Spacer(Modifier.height(12.dp))
                OutlinedTextField(
                    value = state.password, onValueChange = vm::onPasswordChange,
                    label = { Text("Password") }, singleLine = true,
                    visualTransformation = PasswordVisualTransformation(),
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                    modifier = Modifier.fillMaxWidth()
                )
            }
            LoginUiState.Step.Code -> {
                Text(
                    "Enter the 6-digit code we sent to the phone ending ${state.phoneLast4}. (Demo: 123456)",
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Spacer(Modifier.height(24.dp))
                OutlinedTextField(
                    value = state.code, onValueChange = vm::onCodeChange,
                    label = { Text("Code") }, singleLine = true,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        }

        state.error?.let {
            Spacer(Modifier.height(12.dp))
            Text(it, color = MaterialTheme.colorScheme.error)
        }

        Spacer(Modifier.height(24.dp))
        Button(
            onClick = vm::submit,
            enabled = state.canContinue,
            modifier = Modifier.fillMaxWidth().height(52.dp)
        ) {
            if (state.isLoading) CircularProgressIndicator(Modifier.size(20.dp), strokeWidth = 2.dp)
            else Text(if (state.step == LoginUiState.Step.Credentials) "Continue" else "Verify")
        }

        if (state.step == LoginUiState.Step.Code) {
            TextButton(onClick = vm::backToCredentials) { Text("Use a different account") }
        }
    }
}
