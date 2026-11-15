package com.example.valelite

import com.example.valelite.data.api.BankApi
import com.example.valelite.data.api.Network
import com.example.valelite.data.repo.AuthRepository
import com.example.valelite.data.repo.BankRepository
import com.example.valelite.data.repo.SessionRepository

// Creates each shared object once, in order: session → api → bank → auth.
object AppGraph {

    val session: SessionRepository = SessionRepository()

    val api: BankApi = Network.createApi(
        token = { session.token.value },
        onUnauthorized = { onSessionExpired() }
    )

    val bank: BankRepository = BankRepository(api)

    val auth: AuthRepository = AuthRepository(api, session, bank)

    private fun onSessionExpired() {
        session.signOut()
        bank.clear()
    }
}