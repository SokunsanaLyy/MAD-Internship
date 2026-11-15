package com.example.valelite.data.api

import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Response
import retrofit2.HttpException
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import java.io.IOException
import java.util.concurrent.TimeUnit

object Network {

    const val BASE_URL = "http://localhost:3000/"

    val json = Json {
        ignoreUnknownKeys = true
        explicitNulls = false
    }

    fun createApi(token: () -> String?, onUnauthorized: () -> Unit): BankApi {
        val client = OkHttpClient.Builder()
            .addInterceptor(AuthInterceptor(token, onUnauthorized))
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(15, TimeUnit.SECONDS)
            .build()

        return Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
            .create(BankApi::class.java)
    }
}

/** Adds "Authorization: Bearer <token>" to every request, and ends the session on a 401. */
class AuthInterceptor(
    private val token: () -> String?,
    private val onUnauthorized: () -> Unit
) : Interceptor {

    override fun intercept(chain: Interceptor.Chain): Response {
        val current = token()
        val request = chain.request().newBuilder()
            .header("Accept", "application/json")
            .apply { if (current != null) header("Authorization", "Bearer $current") }
            .build()

        val response = chain.proceed(request)
        // Only a request that carried a token can "expire". A wrong password is also a 401, but has no token.
        if (response.code == 401 && current != null) onUnauthorized()
        return response
    }
}

fun Throwable.userMessage(): String = when (this) {
    is HttpException -> {
        val body = response()?.errorBody()?.string()
        val parsed = body?.let { runCatching { Network.json.decodeFromString(ApiErrorBody.serializer(), it) }.getOrNull() }
        parsed?.message ?: "Something went wrong (${code()})."
    }
    is IOException -> "Can't reach Vale: ${message}"
    else -> message ?: "Something went wrong."
}
