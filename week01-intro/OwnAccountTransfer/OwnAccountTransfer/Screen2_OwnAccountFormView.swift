import SwiftUI

// SCREEN 2 — Own Accounts form
// Layout: sky background → header → icon badge → white sheet with fields → flat "Ok" bar.

struct OwnAccountFormView: View {
    // @State = values this screen owns and can change. The UI redraws when they change.
    @State private var fromAccount: Account? = Account.samples[0]
    @State private var toAccount: Account? = nil
    @State private var amount = ""
    @State private var hasPurpose = false
    @State private var isScheduled = false

    var body: some View {
        ZStack(alignment: .top) {
            SkyBackground()

            VStack(spacing: 0) {
                HeaderBar(title: "Transfers")

                FeatureBadge(icon: "arrow.left.arrow.right", title: "Own Accounts")
                    .padding(.vertical, 16)

                VStack(spacing: 18) {
                    AccountDropdown(label: "From Account", account: fromAccount)
                    AccountDropdown(label: "To Account", account: toAccount)
                    AmountField(amount: $amount)
                    ToggleRow(title: "Purpose", isOn: $hasPurpose)
                    ToggleRow(title: "Schedule Transfer", isOn: $isScheduled)
                    Spacer()
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(
                    UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                        .fill(Color.white)
                )

                // Flat bar that runs under the home indicator.
                PrimaryButton(title: "Ok", cornerRadius: 0)
                    .background(Color.brandNavy.ignoresSafeArea(edges: .bottom))
            }
        }
    }
}

// Rounded icon tile with a label underneath.
struct FeatureBadge: View {
    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color.brandIndigo))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white, lineWidth: 2))
            Text(title)
                .font(.caption)
                .foregroundStyle(.white)
        }
    }
}

// Empty: label shown as placeholder inside the box.
// Filled: label floats on the border, account number + balance on the right.
struct AccountDropdown: View {
    let label: String
    let account: Account?

    var body: some View {
        HStack {
            if let account {
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(account.number)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(account.formattedBalance) \(account.currency)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(account.currencyColor)
                }
            } else {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            FieldAccessory(systemName: "arrowtriangle.down.fill")
        }
        .outlinedBox()
        .overlay(alignment: .topLeading) {
            if account != nil { FloatingLabel(text: label) }
        }
    }
}

struct AmountField: View {
    // @Binding = a two-way link to a @State owned by the parent screen.
    @Binding var amount: String

    var body: some View {
        HStack {
            TextField("Amount", text: $amount)
                .keyboardType(.decimalPad)
                .font(.subheadline)
            FieldAccessory(systemName: "info", color: .brandNavy)
        }
        .outlinedBox()
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(title, isOn: $isOn)
            .font(.subheadline)
            .foregroundStyle(Color.brandNavy)
            .tint(Color.brandNavy)
    }
}

#Preview { OwnAccountFormView() }
