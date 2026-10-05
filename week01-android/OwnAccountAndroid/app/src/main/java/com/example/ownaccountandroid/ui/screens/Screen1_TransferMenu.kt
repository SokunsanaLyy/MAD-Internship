package com.example.ownaccountandroid.ui.screens

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowRight
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material.icons.filled.MonetizationOn
import androidx.compose.material.icons.filled.People
import androidx.compose.material.icons.filled.Public
import androidx.compose.material.icons.filled.Smartphone
import androidx.compose.material.icons.filled.SwapHoriz
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.shadow
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ownaccountandroid.ui.AppColors
import com.example.ownaccountandroid.ui.HeaderBar
import com.example.ownaccountandroid.ui.OwnAccountTheme
import com.example.ownaccountandroid.ui.SkyBackground

// SCREEN 1 — Transfers menu
// Layout: sky background → header → illustration → grey sheet with a list of cards.

data class TransferOption(
    val icon: ImageVector,
    val tint: Color,
    val title: String,
    val subtitle: String,
    val hasSubmenu: Boolean   // shows the small gold arrow
)

private val options = listOf(
    TransferOption(Icons.Filled.SwapHoriz, AppColors.BrandIndigo, "Own Accounts", "Own account transfers", false),
    TransferOption(Icons.Filled.People, AppColors.BrandNavy, "Bank Accounts | Phone", "Transfer to bank accounts | phone numbers", false),
    TransferOption(Icons.Filled.AccountBalance, Color(0xFF8E44AD), "Local Transfers", "Transfer to banks | MFIs | wallets", true),
    TransferOption(Icons.Filled.Public, Color(0xFF1ABC9C), "International Transfers", "Transfer worldwide to banks | agents", true),
    TransferOption(Icons.Filled.CreditCard, Color(0xFFE84393), "Card Transfers", "Transfer to other bank cards", true)
)

// The screen only REPORTS taps through callbacks. It doesn't navigate by itself —
// AppNavHost decides what each tap does. This keeps screens reusable and easy to preview.
@Composable
fun TransferMenuScreen(
    onBack: () -> Unit = {},
    onOwnAccounts: () -> Unit = {}
) {
    val context = LocalContext.current

    Box(Modifier.fillMaxSize()) {
        SkyBackground()

        Column(Modifier.fillMaxSize().statusBarsPadding()) {
            HeaderBar(
                title = "Transfers",
                showsInfo = true,
                onBack = onBack,
                onInfo = {
                    Toast.makeText(context, "Move money between your accounts or to others", Toast.LENGTH_SHORT).show()
                }
            )

            HeroIllustration(Modifier.fillMaxWidth().height(150.dp))

            // Grey sheet with only the TOP corners rounded.
            LazyColumn(
                verticalArrangement = Arrangement.spacedBy(10.dp),
                contentPadding = PaddingValues(16.dp),
                modifier = Modifier
                    .fillMaxSize()
                    .clip(RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp))
                    .background(AppColors.Surface)
                    .navigationBarsPadding()
            ) {
                items(options, key = { it.title }) { option ->
                    MenuRow(option, onClick = {
                        if (option.title == "Own Accounts") {
                            onOwnAccounts()
                        } else {
                            // Only Own Accounts is part of this project; the others give feedback instead of doing nothing.
                            Toast.makeText(context, "${option.title} is coming soon", Toast.LENGTH_SHORT).show()
                        }
                    })
                }
            }
        }
    }
}

// One card in the list: icon tile | divider | title + subtitle | arrow
@Composable
fun MenuRow(option: TransferOption, onClick: () -> Unit = {}) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        // Same look as .card(), written out so `clickable` sits between the background and
        // the padding: the whole card is tappable and the ripple stays inside the rounded corners.
        modifier = Modifier
            .fillMaxWidth()
            .shadow(3.dp, RoundedCornerShape(14.dp))
            .clip(RoundedCornerShape(14.dp))
            .background(Color.White)
            .clickable(onClick = onClick)
            .padding(14.dp)
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(34.dp).clip(RoundedCornerShape(9.dp)).background(option.tint)
        ) {
            Icon(option.icon, contentDescription = null, tint = Color.White, modifier = Modifier.size(18.dp))
        }

        Box(Modifier.width(1.dp).height(30.dp).background(AppColors.FieldBorder))

        Column(Modifier.weight(1f)) {
            Text(option.title, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = AppColors.BrandNavy)
            Text(option.subtitle, fontSize = 12.sp, color = AppColors.TextSecondary)
        }

        if (option.hasSubmenu) {
            Icon(Icons.AutoMirrored.Filled.ArrowRight, contentDescription = null, tint = AppColors.Gold)
        }
    }
}

// Phone + floating coins, built from Material icons (replace with your own image if you have one).
@Composable
fun HeroIllustration(modifier: Modifier = Modifier) {
    Box(contentAlignment = Alignment.Center, modifier = modifier) {
        Icon(
            Icons.Filled.Smartphone, contentDescription = null, tint = Color.White,
            modifier = Modifier.size(90.dp).rotate(-15f)
        )
        Coin(26.dp, (-60).dp, (-30).dp)
        Coin(30.dp, 55.dp, (-45).dp)
        Coin(22.dp, 62.dp, 25.dp)
        Coin(20.dp, (-50).dp, 38.dp)
        Coin(18.dp, 15.dp, (-62).dp)
    }
}

@Composable
private fun Coin(size: Dp, x: Dp, y: Dp) {
    Icon(
        Icons.Filled.MonetizationOn, contentDescription = null, tint = AppColors.Gold,
        modifier = Modifier.offset(x, y).size(size).clip(RoundedCornerShape(50)).background(Color.White)
    )
}

@Preview(showSystemUi = true)
@Composable
private fun TransferMenuPreview() = OwnAccountTheme { TransferMenuScreen() }
