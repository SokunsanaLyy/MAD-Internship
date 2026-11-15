package com.example.valelite

import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.valelite.ui.card.CardScreen
import com.example.valelite.ui.home.HomeScreen
import com.example.valelite.ui.login.LoginScreen
import com.example.valelite.ui.transfer.TransferScreen

@Composable
fun AppNavHost() {
    val token by AppGraph.session.token.collectAsStateWithLifecycle()

    if (token == null) {
        LoginScreen()
    } else {
        MainNavHost()
    }
}

@Composable
private fun MainNavHost() {
    val nav = rememberNavController()

    NavHost(navController = nav, startDestination = "home") {
        composable("home") {
            HomeScreen(
                onTransfer = { nav.navigate("transfer") },
                onCard = { nav.navigate("card") }
            )
        }
        composable("transfer") {
            TransferScreen(onDone = { nav.popBackStack() })
        }
        composable("card") {
            CardScreen(onBack = { nav.popBackStack() })
        }
    }
}
