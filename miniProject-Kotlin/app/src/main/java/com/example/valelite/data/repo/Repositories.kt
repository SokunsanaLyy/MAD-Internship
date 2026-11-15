package com.example.valelite.data.repo

import com.example.valelite.data.api.Account
import com.example.valelite.data.api.BankApi
import com.example.valelite.data.api.Card
import com.example.valelite.data.api.CardStatusRequest
import com.example.valelite.data.api.LoginRequest
import com.example.valelite.data.api.LoginResponse
import com.example.valelite.data.api.Transaction
import com.example.valelite.data.api.TransferRequest
import com.example.valelite.data.api.VerifyRequest
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

class SessionRepository {

    private val _token = MutableStateFlow<String?>(null)
    val token: StateFlow<String?> = _token.asStateFlow()

    fun signIn(token: String) { _token.value = token }
    fun signOut() { _token.value = null }
}

class AuthRepository(
    private val api: BankApi,
    private val session: SessionRepository,
    private val bank: BankRepository
) {
    private var challenge: LoginResponse? = null

    suspend fun login(email: String, password: String): String {
        val response = api.login(LoginRequest(email.trim(), password))
        challenge = response
        return response.phoneLast4
    }

    suspend fun verify(code: String) {
        val challengeId = challenge?.challengeId ?: error("Please sign in again.")
        val token = api.verify(VerifyRequest(challengeId, code)).accessToken
        challenge = null
        session.signIn(token)
    }

    suspend fun logout() {
        runCatching { api.logout() }
        session.signOut()
        bank.clear()
    }
}

class BankRepository(private val api: BankApi) {

    private val _accounts = MutableStateFlow<List<Account>>(emptyList())
    val accounts: StateFlow<List<Account>> = _accounts.asStateFlow()

    private val _transactions = MutableStateFlow<List<Transaction>>(emptyList())
    val transactions: StateFlow<List<Transaction>> = _transactions.asStateFlow()

    private val _card = MutableStateFlow<Card?>(null)
    val card: StateFlow<Card?> = _card.asStateFlow()

    suspend fun loadAll() {
        _accounts.value = api.accounts()
        _transactions.value = api.transactions()
        _card.value = api.cards().firstOrNull()
    }

    suspend fun transfer(from: Account, to: Account, amount: Double, note: String) {
        api.transfer(TransferRequest(from.id, to.id, amount, note))
        loadAll()
    }

    suspend fun setCardLocked(locked: Boolean) {
        val current = _card.value ?: return
        _card.value = api.setCardStatus(current.id, CardStatusRequest(if (locked) "locked" else "active"))
    }


    fun clear() {
        _accounts.value = emptyList()
        _transactions.value = emptyList()
        _card.value = null
    }
}
