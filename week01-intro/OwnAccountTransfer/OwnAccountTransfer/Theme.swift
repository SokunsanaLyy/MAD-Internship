import SwiftUI

// MARK: Colours
// One place for every colour in the app. Change a value here and every screen updates.
extension Color {
    static let brandNavy   = Color(red: 0.06, green: 0.20, blue: 0.47)  // buttons, titles
    static let brandIndigo = Color(red: 0.29, green: 0.30, blue: 0.62)  // icon tiles
    static let skyTop      = Color(red: 0.23, green: 0.47, blue: 0.80)  // background gradient top
    static let skyBottom   = Color(red: 0.62, green: 0.80, blue: 0.96)  // background gradient bottom
    static let gold        = Color(red: 0.82, green: 0.62, blue: 0.13)  // KHR amounts, arrows
    static let debitRed    = Color(red: 0.80, green: 0.10, blue: 0.10)  // money leaving the account
    static let fieldBorder = Color.gray.opacity(0.25)                   // outlines & dividers
    static let surface     = Color(.systemGray6)                        // light grey panels
    static let avatarGrey  = Color(red: 0.20, green: 0.26, blue: 0.36)
}

// MARK: Sky background
// Blue gradient + a few clouds. Used behind every screen.
struct SkyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.skyTop, .skyBottom], startPoint: .top, endPoint: .bottom)
            cloud(size: 70, x: 60, y: 140)
            cloud(size: 50, x: 320, y: 110)
            cloud(size: 40, x: 250, y: 190)
        }
        .ignoresSafeArea()   // stretch behind the status bar and home indicator
    }

    private func cloud(size: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        Image(systemName: "cloud.fill")
            .font(.system(size: size))
            .foregroundStyle(Color.white.opacity(0.55))
            .position(x: x, y: y)
    }
}

// MARK: Reusable modifiers
// A ViewModifier bundles several modifiers under one name, so `.card()` gives the
// same white, rounded, shadowed look everywhere.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.08), radius: 6, y: 2)
    }
}

// The thin-outlined input box used by the form fields.
struct OutlinedBox: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.leading, 12)
            .padding(.trailing, 8)
            .frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 8).stroke(Color.fieldBorder))
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
    func outlinedBox() -> some View { modifier(OutlinedBox()) }
}
