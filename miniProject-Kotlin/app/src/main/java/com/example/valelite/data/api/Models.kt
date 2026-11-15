package com.example.valelite.data.api

import kotlinx.serialization.Serializable


// Authentication

@Serializable
data class LoginRequest(val email: String, val password: String)

@Serializable
data class LoginResponse(val challengeId: String, val phoneLast4: String, val expiresIn: Int)

@Serializable
data class VerifyRequest(val challengeId: String, val code: String)

@Serializable
data class TokenResponse(val accessToken: String, val tokenType: String, val expiresIn: Int)

// Accounts and history

@Serializable
data class Account(
    val id: String,
    val name: String,
    val type: String,
    val last4: String,
    val currency: String,
    val balance: Double,
    val status: String
)

@Serializable
data class Transaction(
    val id: String,
    val title: String,
    val category: String,
    val date: String,
    val amount: Double,
    val icon: String
)

// Card

@Serializable
data class Card(
    val id: String,
    val holderName: String,
    val last4: String,
    val status: String
) {
    val isLocked: Boolean get() = status == "locked"
}

@Serializable
data class CardStatusRequest(val status: String)

// Transfers

@Serializable
data class TransferRequest(
    val fromAccountId: String,
    val toAccountId: String,
    val amount: Double,
    val note: String
)

@Serializable
data class TransferResult(val id: String, val status: String, val amount: Double, val date: String)


@Serializable
data class ApiErrorBody(val error: String? = null, val message: String? = null)
