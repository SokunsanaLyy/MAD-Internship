package com.example.ownaccountandroid.ui

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.KeyboardArrowLeft
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// MARK: - Header bar
// Back button + title (+ optional info icon) + logo on the right.
// onBack / onInfo are callbacks: the header doesn't know WHERE "back" goes —
// the navigation code decides that and passes it in.
@Composable
fun HeaderBar(
    title: String,
    showsInfo: Boolean = false,
    onBack: () -> Unit = {},
    onInfo: () -> Unit = {}
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(10.dp),
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(36.dp)                      // a bit larger = easier to tap
                .clip(CircleShape)
                .background(Color.White.copy(alpha = 0.25f))
                .clickable(onClick = onBack)
        ) {
            Icon(Icons.AutoMirrored.Filled.KeyboardArrowLeft, contentDescription = "Back", tint = Color.White)
        }

        Text(title, color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)

        if (showsInfo) {
            Icon(
                Icons.Outlined.Info, contentDescription = "Info", tint = Color.White,
                modifier = Modifier.size(20.dp).clip(CircleShape).clickable(onClick = onInfo)
            )
        }

        Spacer(Modifier.weight(1f))   // pushes the logo to the right edge

        // Placeholder logo — swap for painterResource(R.drawable.your_logo).
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier.size(30.dp).clip(CircleShape).background(Color.White)
        ) {
            Icon(Icons.Filled.AccountBalance, contentDescription = "Bank logo", tint = AppColors.BrandNavy, modifier = Modifier.size(18.dp))
        }
    }
}

// MARK: - Primary button
// Navy full-width button. cornerRadius 0 = flat bar ("Ok"), 12 = rounded ("Confirm").
@Composable
fun PrimaryButton(
    title: String,
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 12.dp,
    enabled: Boolean = true,
    onClick: () -> Unit = {}
) {
    Button(
        onClick = onClick,
        enabled = enabled,                 // greyed out and not tappable when false
        shape = RoundedCornerShape(cornerRadius),
        colors = ButtonDefaults.buttonColors(
            containerColor = AppColors.BrandNavy,
            disabledContainerColor = AppColors.BrandNavy.copy(alpha = 0.45f)
        ),
        modifier = modifier.fillMaxWidth().height(50.dp)
    ) {
        Text(title, color = Color.White, fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
    }
}

// MARK: - Initials avatar
// "Narin Dev" -> "ND" in a dark circle.
@Composable
fun InitialsAvatar(name: String, size: Dp = 44.dp) {
    val initials = name.split(" ")
        .take(2)
        .mapNotNull { it.firstOrNull()?.toString() }
        .joinToString("")

    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier.size(size).clip(CircleShape).background(AppColors.AvatarGrey)
    ) {
        Text(initials, color = Color.White, fontWeight = FontWeight.SemiBold, fontSize = (size.value * 0.38f).sp)
    }
}

// MARK: - Floating label
// Small label sitting on the top border of an outlined field ("From Account").
@Composable
fun FloatingLabel(text: String) {
    Text(
        text = text,
        fontSize = 11.sp,
        color = AppColors.TextSecondary,
        modifier = Modifier
            .offset(x = 10.dp, y = (-8).dp)
            .background(Color.White)      // hides the border line behind the text
            .padding(horizontal = 4.dp)
    )
}

// MARK: - Small square button used inside fields (dropdown arrow, "i")
@Composable
fun FieldAccessory(icon: ImageVector, tint: Color = AppColors.Gold) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(32.dp)
            .clip(RoundedCornerShape(6.dp))
            .background(AppColors.Surface)
    ) {
        Icon(icon, contentDescription = null, tint = tint, modifier = Modifier.size(18.dp))
    }
}

// MARK: - Label : value row (Success screen details)
@Composable
fun InfoRow(label: String, value: String, modifier: Modifier = Modifier, valueColor: Color = Color.Black) {
    Row(modifier = modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(6.dp)) {
        Text(label, fontSize = 12.sp, color = AppColors.TextSecondary, modifier = Modifier.width(100.dp))
        Text(":", fontSize = 12.sp, color = AppColors.TextSecondary)
        Text(value, fontSize = 12.sp, color = valueColor)
    }
}

// MARK: - Label + custom content row (Verify screen)
// A @Composable lambda parameter lets the caller pass any content as the right-hand side
// (same idea as @ViewBuilder in SwiftUI).
@Composable
fun DetailRow(label: String, content: @Composable RowScope.() -> Unit) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Text(label, fontSize = 12.sp, color = AppColors.TextSecondary, modifier = Modifier.width(95.dp))
        content()
    }
}

// MARK: - Dashed divider (receipt "tear line")
// Canvas = free drawing; PathEffect.dashPathEffect makes the dashes (5 on, 4 off).
@Composable
fun DashedLine() {
    Canvas(modifier = Modifier.fillMaxWidth().height(1.dp)) {
        drawLine(
            color = AppColors.FieldBorder,
            start = Offset(0f, size.height / 2),
            end = Offset(size.width, size.height / 2),
            strokeWidth = 1.dp.toPx(),
            pathEffect = PathEffect.dashPathEffect(floatArrayOf(5.dp.toPx(), 4.dp.toPx()))
        )
    }
}