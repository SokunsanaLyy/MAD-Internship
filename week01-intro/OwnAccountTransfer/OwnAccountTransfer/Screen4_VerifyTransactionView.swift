import SwiftUI

// SCREEN 4 — Verify transaction
// Layout: header → translucent panel with title + details card → Confirm button at the bottom.

struct VerifyTransactionView: View {
    var summary: TransferSummary = .sample

    var body: some View {
        ZStack(alignment: .top) {
            SkyBackground()

            VStack(spacing: 0) {
                HeaderBar(title: "Transfers")

                VStack(spacing: 12) {
                    Text("Please verify transaction")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.brandNavy)

                    detailsCard
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.4)))
                .padding(.horizontal, 16)
                .padding(.top, 60)

                Spacer()

                PrimaryButton(title: "Confirm")
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
            }
        }
    }

    // Split into a computed property to keep `body` short and readable.
    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Recipient
            HStack(spacing: 12) {
                InitialsAvatar(name: summary.name)
                VStack(alignment: .leading, spacing: 2) {
                    Text(summary.name).font(.subheadline.bold())
                    Text("\(summary.toAccount) (\(summary.toCurrency))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            DetailRow(label: "Amount") {
                Text(summary.amountText)
                    .font(.title3.bold())
                    .foregroundStyle(Color.gold)
            }

            Divider()

            DetailRow(label: "Transfer From") {
                VStack(alignment: .leading, spacing: 2) {
                    Text(summary.name).font(.subheadline.bold())
                    Text("\(summary.fromAccount) (\(summary.fromCurrency))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            DetailRow(label: "Exchange Rate") {
                Text(summary.exchangeRate).font(.caption)
            }
            DetailRow(label: "Debit Amount") {
                Text(summary.debitText).font(.subheadline.bold())
            }
        }
        .card()
    }
}

#Preview { VerifyTransactionView() }
