package com.example.ownaccountandroid.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

// MARK: - Colours
// One place for every colour in the app. Change a value here and every screen updates.
// (Same idea as `extension Color` in the Swift version.)
object AppColors {
    val BrandNavy   = Color(0xFF0F3378)  // buttons, titles
    val BrandIndigo = Color(0xFF4A4D9E)  // icon tiles
    val SkyTop      = Color(0xFF3B78CC)  // background gradient top
    val SkyBottom   = Color(0xFF9ECCF5)  // background gradient bottom
    val Gold        = Color(0xFFD19E21)  // KHR amounts, arrows
    val DebitRed    = Color(0xFFCC1A1A)  // money leaving the account
    val FieldBorder = Color(0x40808080)  // outlines & dividers (gray, 25%)
    val Surface     = Color(0xFFF2F2F7)  // light grey panels
    val AvatarGrey  = Color(0xFF33425C)
    val TextSecondary = Color(0xFF6B6B70)
}

// MARK: - App theme
// Wraps every screen so Material components (Switch, TextField…) pick up the brand colours.
@Composable
fun OwnAccountTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = AppColors.BrandNavy,
            secondary = AppColors.Gold,
            surface = Color.White,
            background = Color.White
        ),
        content = content
    )
}

// MARK: - Sky background
// Blue gradient + a few clouds. Used behind every screen.
@Composable
fun SkyBackground() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(AppColors.SkyTop, AppColors.SkyBottom)))
    ) {
        Cloud(size = 70.dp, x = 25.dp, y = 105.dp)
        Cloud(size = 50.dp, x = 295.dp, y = 85.dp)
        Cloud(size = 40.dp, x = 230.dp, y = 170.dp)
    }
}

@Composable
private fun Cloud(size: Dp, x: Dp, y: Dp) {
    Icon(
        imageVector = Icons.Filled.Cloud,
        contentDescription = null,
        tint = Color.White.copy(alpha = 0.55f),
        modifier = Modifier
            .offset(x = x, y = y)   // exact position, like .position() in SwiftUI
            .size(size)
    )
}

// MARK: - Reusable modifiers
// A Modifier extension bundles several modifiers under one name, so `.card()` gives the
// same white, rounded, shadowed look everywhere (same as the Swift ViewModifier).
fun Modifier.card(): Modifier = this
    .shadow(elevation = 3.dp, shape = RoundedCornerShape(14.dp))
    .clip(RoundedCornerShape(14.dp))
    .background(Color.White)
    .padding(14.dp)

// The thin-outlined input box used by the form fields.
fun Modifier.outlinedBox(): Modifier = this
    .height(56.dp)
    .border(1.dp, AppColors.FieldBorder, RoundedCornerShape(8.dp))
    .padding(start = 12.dp, end = 8.dp)
