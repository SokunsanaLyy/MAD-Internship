package com.example.ownaccountandroid

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import com.example.ownaccountandroid.navigation.AppNavHost
import com.example.ownaccountandroid.ui.OwnAccountTheme

// The app's single Activity. Compose apps usually have just one: every "screen" is a
// composable, and AppNavHost swaps between them.
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()   // draw behind the status & navigation bars (like ignoresSafeArea)
        setContent {
            OwnAccountTheme {
                AppNavHost()
            }
        }
    }
}
