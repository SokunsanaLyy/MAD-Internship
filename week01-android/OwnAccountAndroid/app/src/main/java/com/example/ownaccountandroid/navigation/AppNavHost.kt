package com.example.ownaccountandroid.navigation

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.activity.compose.LocalActivity
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.ownaccountandroid.ui.TransferViewModel
import com.example.ownaccountandroid.ui.screens.OwnAccountFormScreen
import com.example.ownaccountandroid.ui.screens.SuccessScreen
import com.example.ownaccountandroid.ui.screens.TransferMenuScreen
import com.example.ownaccountandroid.ui.screens.VerifyTransactionScreen

// MARK: - Routes
// Every screen has a unique name ("route"). Navigating = asking the NavController to show a route.
// Screen 3 (Select Account) is not a route: it's a bottom sheet that opens ON TOP of the form.
object Routes {
    const val MENU = "menu"
    const val FORM = "form"
    const val VERIFY = "verify"
    const val SUCCESS = "success"
}

// MARK: - AppNavHost
// The map of the app: which screen belongs to each route, and what each button does.
//
//   menu ──Own Accounts──▶ form ──Ok──▶ verify ──Confirm──▶ success
//    ▲                      ▲  (sheet: Select Account)          │
//    │                      └────────── Repeat / Set Schedule ──┤
//    └──────────────────────────────── Home ────────────────────┘
//
// The NavController keeps a BACK STACK (a pile of visited screens). navigate() puts a screen
// on top; popBackStack() removes the top one. The phone's Back button pops automatically.
@Composable
fun AppNavHost(
    navController: NavHostController = rememberNavController(),
    // viewModel() here = ONE TransferViewModel shared by every screen in the flow.
    viewModel: TransferViewModel = viewModel()
) {
    val activity = LocalActivity.current   // the Activity hosting the app (used to close it)

    NavHost(navController = navController, startDestination = Routes.MENU) {

        // SCREEN 1 — Transfers menu
        composable(Routes.MENU) {
            TransferMenuScreen(
                onBack = { activity?.finish() },          // first screen: Back closes the app
                onOwnAccounts = {
                    viewModel.startNew()                  // fresh, empty form every time
                    navController.navigate(Routes.FORM)
                }
            )
        }

        // SCREEN 2 (+ SCREEN 3 as a bottom sheet) — Own Accounts form
        composable(Routes.FORM) {
            OwnAccountFormScreen(
                viewModel = viewModel,
                onBack = { navController.popBackStack() },
                // launchSingleTop: a quick double-tap on "Ok" won't open Verify twice.
                onContinue = { navController.navigate(Routes.VERIFY) { launchSingleTop = true } }
            )
        }

        // SCREEN 4 — Verify
        composable(Routes.VERIFY) {
            // `remember` freezes the summary when this screen opens. Without it, the screen
            // would recalculate after Confirm moves the money (new balances) while it's still
            // animating out.
            val summary = remember { viewModel.buildSummary() }
            if (summary != null) {
                VerifyTransactionScreen(
                    summary = summary,
                    onBack = { navController.popBackStack() },
                    onConfirm = {
                        viewModel.confirm()
                        navController.navigate(Routes.SUCCESS) {
                            // Remove Form and Verify from the back stack, so pressing Back on
                            // the receipt goes to the menu — the transfer can't be sent twice.
                            popUpTo(Routes.MENU)
                        }
                    }
                )
            } else {
                // Safety net: if the form somehow isn't valid, go back to it.
                LaunchedEffect(Unit) { navController.popBackStack() }
            }
        }

        // SCREEN 5 — Success receipt
        composable(Routes.SUCCESS) {
            val receipt = viewModel.lastReceipt
            if (receipt != null) {
                SuccessScreen(
                    summary = receipt,
                    accounts = viewModel.accounts,
                    onHome = { navController.popBackStack(Routes.MENU, inclusive = false) },
                    onRepeat = {
                        viewModel.repeatLast(scheduled = false)   // same accounts & amount, send now
                        navController.navigate(Routes.FORM) { popUpTo(Routes.MENU) }
                    },
                    onSetSchedule = {
                        viewModel.repeatLast(scheduled = true)    // same transfer, as a scheduled one
                        navController.navigate(Routes.FORM) { popUpTo(Routes.MENU) }
                    }
                )
            } else {
                LaunchedEffect(Unit) { navController.popBackStack(Routes.MENU, inclusive = false) }
            }
        }
    }
}