import SwiftUI

// SCREEN 5 — Success receipt
// Layout: bank name → check badge overlapping a receipt card → "Set Schedule" pill → action bar.

struct SuccessView: View {
    var summary: TransferSummary = .sample
    @State private var isExpanded = true   // chevron shows/hides the detail rows

    var body: some View {
        ZStack(alignment: .top) {
            SkyBackground()

            VStack(spacing: 0) {
                // Placeholder — replace with Image("YourLogo").
                Text("My Bank")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                    .padding(.top, 8)

                // Badge sits on top of the card: ZStack + top padding on the card.
                ZStack(alignment: .top) {
                    receiptCard
                        .padding(.top, 34)
                    SuccessBadge()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer()

                Label("Set Schedule", systemImage: "calendar")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.brandNavy)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white))
                    .padding(.bottom, 10)

                ActionBar()
                    .padding(.bottom, 8)
            }
        }
    }

    private var receiptCard: some View {
        VStack(spacing: 14) {
            Text("Success")
                .font(.headline)
                .foregroundStyle(Color.brandNavy)
                .padding(.top, 38)   // leaves room under the badge

            // "Transferred to" box
            HStack(spacing: 12) {
                InitialsAvatar(name: summary.name)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Transferred to").font(.caption2).foregroundStyle(.secondary)
                    Text(summary.name).font(.subheadline.bold())
                    Text(summary.amountText)
                        .font(.title3.bold())
                        .foregroundStyle(Color.debitRed)
                }
                Spacer()
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.surface))

            DashedLine()

            // Details (collapsible)
            VStack(spacing: 8) {
                HStack {
                    InfoRow(label: "From Account", value: summary.name)
                    Button { isExpanded.toggle() } label: {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.bold())
                            .foregroundStyle(Color.gold)
                    }
                }

                if isExpanded {
                    InfoRow(label: "Account No.", value: "\(summary.fromAccount) (\(summary.fromCurrency))")
                    InfoRow(label: "Debit Amount", value: summary.debitText, valueColor: .debitRed)
                    Divider()
                    InfoRow(label: "Exchange Rate", value: summary.exchangeRate)
                    InfoRow(label: "To Account", value: summary.name)
                    InfoRow(label: "Account No.", value: "\(summary.toAccount) (\(summary.toCurrency))")
                    Divider()
                    InfoRow(label: "Reference No.", value: summary.reference)
                }
            }
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
    }
}

// Navy circle with a gold tick and a white ring.
struct SuccessBadge: View {
    var body: some View {
        Image(systemName: "checkmark")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(Color.gold)
            .frame(width: 64, height: 64)
            .background(Circle().fill(Color.brandNavy))
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
    }
}

// Bottom row of four actions.
struct ActionItem: Identifiable {
    var id: String { title }
    let icon: String
    let title: String
}

struct ActionBar: View {
    private let items = [
        ActionItem(icon: "house", title: "Home"),
        ActionItem(icon: "arrow.clockwise", title: "Repeat"),
        ActionItem(icon: "wallet.pass", title: "Accounts"),
        ActionItem(icon: "square.and.arrow.up", title: "Share")
    ]

    var body: some View {
        HStack {
            ForEach(items) { item in
                Button {} label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.icon).font(.system(size: 17))
                        Text(item.title).font(.caption2)
                    }
                    .foregroundStyle(Color.brandNavy)
                    .frame(maxWidth: .infinity)   // four equal-width slots
                }
            }
        }
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.white.opacity(0.92)))
        .padding(.horizontal, 20)
    }
}

#Preview { SuccessView() }
