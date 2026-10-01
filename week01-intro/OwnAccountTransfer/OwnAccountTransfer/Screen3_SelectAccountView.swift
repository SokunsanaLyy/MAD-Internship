import SwiftUI

// SCREEN 3 — Select Account
// The form from Screen 2, dimmed, with an account list rising from the bottom.

struct SelectAccountScreen: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            OwnAccountFormView()              // screen behind
            Color.black.opacity(0.45)         // dimming layer
                .ignoresSafeArea()
            SelectAccountSheet()              // the list
                .ignoresSafeArea(edges: .bottom)
        }
    }
}

struct SelectAccountSheet: View {
    var accounts: [Account] = Account.samples
    var onSelect: (Account) -> Void = { _ in }   // hook for later, when you add logic

    var body: some View {
        VStack(spacing: 0) {
            Text("Select Account")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    LinearGradient(colors: [Color.brandNavy.opacity(0.8), Color.brandNavy],
                                   startPoint: .top, endPoint: .bottom)
                )

            ForEach(accounts) { account in
                Button { onSelect(account) } label: {
                    AccountRow(account: account)
                }
                .buttonStyle(.plain)
                Divider()
            }
        }
        .padding(.bottom, 24)   // room for the home indicator
        .background(Color.surface)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 20, topTrailingRadius: 20))
    }
}

// Two lines: number + currency / type + balance
struct AccountRow: View {
    let account: Account

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(account.number)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.brandNavy)
                Spacer()
                Text(account.currency)
                    .font(.caption.bold())
                    .foregroundStyle(account.currencyColor)
            }
            HStack {
                Text(account.type)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(account.formattedBalance)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(account.currencyColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())   // makes the whole row tappable, not just the text
    }
}

#Preview { SelectAccountScreen() }
