// xcode: set sdk=iOS

import SwiftUI

// SCREEN 1  Transfers menu
// Layout: sky background → header → illustration → grey sheet with a list of cards.

struct TransferOption: Identifiable {
    var id: String { title }
    let icon: String
    let tint: Color
    let title: String
    let subtitle: String
    let hasSubmenu: Bool   // shows the small gold arrow
}

struct TransferMenuView: View {
    private let options: [TransferOption] = [
        .init(icon: "arrow.left.arrow.right", tint: .brandIndigo,
              title: "Own Accounts", subtitle: "Own account transfers", hasSubmenu: false),
        .init(icon: "person.2.fill", tint: .brandNavy,
              title: "Bank Accounts | Phone", subtitle: "Transfer to bank accounts | phone numbers", hasSubmenu: false),
        .init(icon: "building.columns.fill", tint: .purple,
              title: "Local Transfers", subtitle: "Transfer to banks | MFIs | wallets", hasSubmenu: true),
        .init(icon: "globe.asia.australia.fill", tint: .teal,
              title: "International Transfers", subtitle: "Transfer worldwide to banks | agents", hasSubmenu: true),
        .init(icon: "creditcard.fill", tint: .pink,
              title: "Card Transfers", subtitle: "Transfer to other bank cards", hasSubmenu: true)
    ]

    var body: some View {
        ZStack(alignment: .top) {
            SkyBackground()

            VStack(spacing: 0) {
                HeaderBar(title: "Transfers", showsInfo: true)

                HeroIllustration()
                    .frame(height: 150)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(options) { option in
                            MenuRow(option: option)
                        }
                    }
                    .padding(16)
                }
                // Grey sheet with only the TOP corners rounded (iOS 17+).
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .fill(Color.surface)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}

// One card in the list: icon tile | divider | title + subtitle | arrow
struct MenuRow: View {
    let option: TransferOption

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: option.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(RoundedRectangle(cornerRadius: 9).fill(option.tint))

            Rectangle()
                .fill(Color.fieldBorder)
                .frame(width: 1, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(option.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.brandNavy)
                Text(option.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if option.hasSubmenu {
                Image(systemName: "arrowtriangle.right.fill")
                    .font(.caption2)
                    .foregroundStyle(Color.gold)
            }
        }
        .card()
    }
}

// Phone + floating coins, built from SF Symbols (replace with your own image if you have one).
struct HeroIllustration: View {
    private let coins: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
        (-60, -30, 26), (55, -45, 30), (62, 25, 22), (-50, 38, 20), (15, -62, 18)
    ]

    var body: some View {
        ZStack {
            Image(systemName: "iphone.gen3")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .rotationEffect(.degrees(-15))

            ForEach(coins.indices, id: \.self) { i in
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: coins[i].size))
                    .foregroundStyle(Color.white, Color.gold)
                    .offset(x: coins[i].x, y: coins[i].y)
            }
        }
    }
}

#Preview { TransferMenuView() }
