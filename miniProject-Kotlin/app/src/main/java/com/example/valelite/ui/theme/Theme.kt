package com.example.valelite.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

val ValeInk = Color(0xFF142820)
val ValeInkFillDark = Color(0xFF1E3B2C)
val ValeLime = Color(0xFFBDF487)
val ValeGreen = Color(0xFF3F7A50)
val ValeGreenDark = Color(0xFF7CC491)
val ValeRed = Color(0xFFC0392B)
val ValeRedDark = Color(0xFFFF6F61)

private val LightColors = lightColorScheme(
    primary = ValeInk,
    onPrimary = Color.White,
    secondary = ValeLime,
    onSecondary = ValeInk,
    tertiary = ValeGreen,
    background = Color(0xFFF7F8F4),
    onBackground = ValeInk,
    surface = Color.White,
    onSurface = ValeInk,
    surfaceVariant = Color(0xFFEAF1E5),
    onSurfaceVariant = Color(0xFF6B7A72),
    outline = Color(0xFFE1E6DD),
    error = ValeRed
)

private val DarkColors = darkColorScheme(
    primary = ValeInkFillDark,
    onPrimary = Color.White,
    secondary = ValeLime,
    onSecondary = ValeInk,
    tertiary = ValeGreenDark,
    background = Color(0xFF0F1613),
    onBackground = Color(0xFFEEF3EA),
    surface = Color(0xFF19231E),
    onSurface = Color(0xFFEEF3EA),
    surfaceVariant = Color(0xFF22332A),
    onSurfaceVariant = Color(0xFF9DABA3),
    outline = Color(0xFF2D3B34),
    error = ValeRedDark
)

/** Follows the phone's light/dark setting. */
@Composable
fun ValeTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = if (isSystemInDarkTheme()) DarkColors else LightColors,
        content = content
    )
}
