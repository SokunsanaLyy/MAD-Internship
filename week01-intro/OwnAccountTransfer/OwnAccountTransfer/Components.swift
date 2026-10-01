// xcode: set sdk=iOS

import SwiftUI

// MARK: - Header bar
// Back button + title (+ optional info icon) + logo on the right.
struct HeaderBar: View {
    let title: String
    var showsInfo = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "chevron.left")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(Circle().fill(Color.white.opacity(0.25)))

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            if showsInfo {
                Image(systemName: "info.circle")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }

            Spacer()

            // Placeholder logo — swap for Image("YourLogo") from Assets.
            Image(systemName: "building.columns.circle.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.white, Color.brandNavy)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Primary button
// Navy full-width button. cornerRadius 0 = flat bar ("Ok"), 12 = rounded ("Confirm").
struct PrimaryButton: View {
    let title: String
    var cornerRadius: CGFloat = 12
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.brandNavy))
        }
    }
}

// MARK: - Initials avatar
// "Narin Dev" -> "ND" in a dark circle.
struct InitialsAvatar: View {
    let name: String
    var size: CGFloat = 44

    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(Circle().fill(Color.avatarGrey))
    }
}

// MARK: - Floating label
// Small label sitting on the top border of an outlined field ("From Account").
struct FloatingLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 4)
            .background(Color.white)   // hides the border line behind the text
            .offset(x: 10, y: -7)
    }
}

// MARK: - Small square button used inside fields (dropdown arrow, "i")
struct FieldAccessory: View {
    let systemName: String
    var color: Color = .gold

    var body: some View {
        Image(systemName: systemName)
            .font(.caption.bold())
            .foregroundStyle(color)
            .frame(width: 32, height: 32)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.surface))
    }
}

// MARK: - Label : value row (Success screen details)
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text(label)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            Text(":").foregroundStyle(.secondary)
            Text(value).foregroundStyle(valueColor)
            Spacer(minLength: 0)
        }
        .font(.caption)
    }
}

// MARK: - Label + custom content row (Verify screen)
// @ViewBuilder lets the caller pass any views as the right-hand side.
struct DetailRow<Content: View>: View {
    let label: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 95, alignment: .leading)
            content
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Dashed divider (receipt "tear line")
struct DashedLine: View {
    var body: some View {
        HorizontalLine()
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
            .foregroundStyle(Color.fieldBorder)
            .frame(height: 1)
    }
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
