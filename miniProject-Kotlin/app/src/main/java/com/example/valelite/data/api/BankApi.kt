package com.example.valelite.data.api

import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.PATCH
import retrofit2.http.POST
import retrofit2.http.Path

// Retrofit writes the HTTP code for us from these annotations.
interface BankApi {

    @POST("auth/login")
    suspend fun login(@Body body: LoginRequest): LoginResponse

    @POST("auth/verify")
    suspend fun verify(@Body body: VerifyRequest): TokenResponse

    @POST("auth/logout")
    suspend fun logout(): Response<Unit>          // 204, no body

    @GET("accounts")
    suspend fun accounts(): List<Account>

    @GET("transactions")
    suspend fun transactions(): List<Transaction>   // newest first

    @GET("cards")
    suspend fun cards(): List<Card>

    @PATCH("cards/{id}")
    suspend fun setCardStatus(@Path("id") id: String, @Body body: CardStatusRequest): Card

    @POST("transfers")
    suspend fun transfer(@Body body: TransferRequest): TransferResult
}
