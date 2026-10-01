// xcode: set sdk=iOS

import SwiftUI

// Shows all five screens side by side — swipe left/right in the simulator.
// No navigation logic yet; this is just a gallery for checking the UI.
struct ContentView: View {
    var body: some View {
        TabView {
            TransferMenuView()
            OwnAccountFormView()
            SelectAccountScreen()
            VerifyTransactionView()
            SuccessView()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

#Preview { ContentView() }
