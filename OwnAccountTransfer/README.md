# Own Account Transfer: SwiftUI UI Guide

A step-by-step guide to building the UI of the five **Own Account Transfer** screens in SwiftUI.

> **Scope:** UI only. The screens don't navigate to each other yet. `ContentView` shows them as a swipeable gallery so you can check each design.

---

## Table of Contents

1. [Project Setup](#1-project-setup)
2. [Add the Project to Git](#2-add-the-project-to-git)
3. [File Structure](#3-file-structure)
4. [Step 1: Theme (Design System)](#4-step-1-theme-design-system)
5. [Step 2: Models (Sample Data)](#5-step-2-models-sample-data)
6. [Step 3: Reusable Components](#6-step-3-reusable-components)
7. [Step 4: Screen 1, Transfers Menu](#7-step-4-screen-1-transfers-menu)
8. [Step 5: Screen 2, Own Accounts Form](#8-step-5-screen-2-own-accounts-form)
9. [Step 6: Screen 3, Select Account](#9-step-6-screen-3-select-account)
10. [Step 7: Screen 4, Verify Transaction](#10-step-7-screen-4-verify-transaction)
11. [Step 8: Screen 5, Success Receipt](#11-step-8-screen-5-success-receipt)
12. [Step 9: ContentView (Preview Gallery)](#12-step-9-contentview-preview-gallery)
13. [SwiftUI Concepts Cheat Sheet](#13-swiftui-concepts-cheat-sheet)
14. [UI/UX Principles Used](#14-uiux-principles-used)
15. [Placeholders to Replace](#15-placeholders-to-replace)
16. [Troubleshooting](#16-troubleshooting)
17. [Next Steps](#17-next-steps)

---

## 1. Project Setup

1. Open **Xcode** and choose **File → New → Project…**
2. Choose **iOS → App**, then **Next**.
3. Fill in:
   - **Product Name:** `OwnAccountTransfer`
   - **Interface:** SwiftUI
   - **Language:** Swift
4. Select the project in the navigator, go to **Target → General → Minimum Deployments**, and set it to **iOS 17.0**.
   - Two features need iOS 17: `UnevenRoundedRectangle` (sheets with only the top corners rounded) and the `#Preview` macro.
5. Delete the `ContentView.swift` Xcode created.
6. Drag all the `.swift` files from this folder into the project navigator and tick **Copy items if needed**.
7. Press **⌘R** to run. Swipe left and right through the screens.
8. To see one screen alone, open its file and show the Canvas (**⌥⌘↩**). Every screen has its own `#Preview`.

---

## 2. Add the Project to Git

Choose the option that fits your situation:

- **[2.1](#21-add-to-an-existing-git-repo)**: you already have a Git repo and want the project inside it.
- **[2.2](#22-create-a-new-git-repo)**: you want a new repo just for this project.

> **Golden rule:** a project must never contain a Git repo inside another Git repo. The repo should have exactly **one** `.git` folder, at the top.

### 2.1 Add to an Existing Git Repo

#### Step 1: Get the existing repo on your Mac

If it's already on your Mac, skip this step. Otherwise, clone it:

```bash
cd ~/Desktop        # the folder the repo will be downloaded into (see note below)
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
git pull            # make sure you have the latest version
```

> **Where should the project live?** `cd ~/Desktop` picks the folder on your Mac that the repo is downloaded into. `git clone` then creates a `<your-repo>` folder inside it, so the project ends up at `~/Desktop/<your-repo>`.
>
> The Desktop is only an example. Any folder works, and many developers keep their projects in one place:
>
> ```bash
> mkdir -p ~/Developer   # create the folder once
> cd ~/Developer
> ```
>
> If you choose a different folder, replace `~/Desktop` with it in every command in this section.
>
> Avoid folders synced by iCloud Drive (such as Desktop and Documents when iCloud syncing is on). Syncing can conflict with Git and with Xcode's build files.
>
> **Already cloned the repo?** Skip the clone and `cd` into the folder where it already is. To find it, open the folder in Finder and drag it into the Terminal window after typing `cd ` (with a space). Terminal fills in the path.

#### Step 2: Put the Xcode project inside the repo folder

**If you haven't created the Xcode project yet:**

1. In Xcode, choose **File → New → Project → iOS → App** and name it `OwnAccountTransfer`.
2. In the save dialog, go to your repo folder.
3. **Untick "Create Git repository on my Mac"**, because the repo already has Git.
4. Click **Create**, then follow [Project Setup](#1-project-setup) steps 4–6.

**If you already created the project somewhere else:**

1. Close Xcode.
2. Move the whole project folder, the one that contains `OwnAccountTransfer.xcodeproj`, into the repo:

   ```bash
   mv ~/Desktop/OwnAccountTransfer ~/Desktop/<your-repo>/
   ```

3. Check whether the project has its own Git folder:

   ```bash
   ls -a ~/Desktop/<your-repo>/OwnAccountTransfer
   ```

   If you see `.git` in the list, delete it. Otherwise Git treats the project as a separate repo and won't track its files:

   ```bash
   rm -rf ~/Desktop/<your-repo>/OwnAccountTransfer/.git
   ```

   > ⚠️ Only delete the `.git` **inside the project folder**, never the one at the top of your repo.

The result should look like this:

```
<your-repo>/
├── .git/                      ← the repo's only .git
├── .gitignore
├── (your existing files…)
└── OwnAccountTransfer/
    ├── OwnAccountTransfer.xcodeproj
    └── OwnAccountTransfer/
        ├── Theme.swift
        ├── ...
        └── README.md
```

#### Step 3: Add Xcode entries to `.gitignore`

Open the `.gitignore` at the top of your repo, or create one if it's missing, and add:

```gitignore
# Xcode
xcuserdata/
*.xcuserstate
DerivedData/
build/

# macOS
.DS_Store
```

These are personal settings and build output. They change constantly and shouldn't be shared.

#### Step 4: Commit and push

```bash
cd ~/Desktop/<your-repo>
git status                     # check the new files are listed and xcuserdata is not
git add .
git commit -m "Add Own Account Transfer SwiftUI UI project"
git push
```

If the repo uses a branch workflow, create a branch first and push that instead:

```bash
git checkout -b feature/own-account-ui
git add .
git commit -m "Add Own Account Transfer SwiftUI UI project"
git push -u origin feature/own-account-ui
```

Then open a Pull Request on GitHub to merge it.

#### Step 5: Open it from the repo

Open `OwnAccountTransfer.xcodeproj` **from inside the repo folder** from now on. Xcode notices the parent repo automatically, so you can commit with **⌥⌘C** (**Integrate → Commit**) as usual.

#### Common problem: project files missing on GitHub

If `git status` shows `OwnAccountTransfer/` as a single entry and its files don't show up on GitHub, the project's own `.git` folder is still there. Remove it as in Step 2, then run:

```bash
git rm --cached OwnAccountTransfer
git add OwnAccountTransfer
git commit -m "Track Xcode project files"
git push
```

### 2.2 Create a New Git Repo

#### Option A: Inside Xcode

1. **Create the local repo**
   - **New project:** in the save dialog, tick **"Create Git repository on my Mac"**.
   - **Existing project:** choose **Integrate → New Git Repository…** in the menu bar and click **Create**. In older Xcode versions this menu is called **Source Control**.
2. **Add a `.gitignore`**: use the entries from [2.1 Step 3](#step-3-add-xcode-entries-to-gitignore). Put the file in the folder that contains `.xcodeproj`.
3. **First commit:** choose **Integrate → Commit…** (⌥⌘C), tick all the files, write a message and click **Commit**.
4. **Connect GitHub:** go to **Xcode → Settings → Accounts**, click **+**, choose **GitHub**, and sign in with a **Personal Access Token**. To make a token on GitHub: **Settings → Developer settings → Personal access tokens → Tokens (classic)**, with the **repo** scope.
5. **Push:** open the Source Control navigator with **⌘2** and choose the **Repositories** tab. Right-click **Remotes → New "OwnAccountTransfer" Remote…**, choose Private or Public, and click **Create**.

#### Option B: Terminal

```bash
cd ~/Desktop/OwnAccountTransfer          # folder containing the .xcodeproj
# create .gitignore with the entries from 2.1 Step 3, then:
git init
git add .
git commit -m "Initial UI for Own Account Transfer screens"
git branch -M main
```

Create an **empty** repo on github.com. Don't tick "Add a README". Then run:

```bash
git remote add origin https://github.com/<your-username>/OwnAccountTransfer.git
git push -u origin main
```

When Git asks for a password, paste your **Personal Access Token**. Your GitHub password won't work here.

### 2.3 Everyday Workflow

```bash
git add .
git commit -m "Add Screen 3 Select Account sheet"
git push
```

Or in Xcode, press **⌥⌘C**, tick **"Push to remote"**, and click **Commit**.

> **Tip:** Commit after each screen. That makes your progress easy to show, and you can roll back one screen if something breaks.

---

## 3. File Structure

```
OwnAccountTransfer/
├── Theme.swift                         ← colours, background, reusable modifiers
├── Models.swift                        ← Account + TransferSummary sample data
├── Components.swift                    ← small reusable views
├── Screen1_TransferMenuView.swift      ← Transfers menu
├── Screen2_OwnAccountFormView.swift    ← Own Accounts form
├── Screen3_SelectAccountView.swift     ← Select Account sheet
├── Screen4_VerifyTransactionView.swift ← Verify transaction
├── Screen5_SuccessView.swift           ← Success receipt
└── ContentView.swift                   ← swipeable gallery of all screens
```

**Build order:** Theme → Models → Components → Screens → ContentView.
Each layer uses the ones before it, so going in this order means there's never a missing type.

---

## 4. Step 1: Theme (Design System)

**File:** `Theme.swift`

A *design system* is one place that defines how the app looks. When the brand colour changes, you edit one line instead of hunting through every screen.

### 4.1 Colours

```swift
extension Color {
    static let brandNavy   = Color(red: 0.06, green: 0.20, blue: 0.47)  // buttons, titles
    static let brandIndigo = Color(red: 0.29, green: 0.30, blue: 0.62)  // icon tiles
    static let skyTop      = Color(red: 0.23, green: 0.47, blue: 0.80)
    static let skyBottom   = Color(red: 0.62, green: 0.80, blue: 0.96)
    static let gold        = Color(red: 0.82, green: 0.62, blue: 0.13)  // KHR amounts, arrows
    static let debitRed    = Color(red: 0.80, green: 0.10, blue: 0.10)
    static let fieldBorder = Color.gray.opacity(0.25)
    static let surface     = Color(.systemGray6)
    static let avatarGrey  = Color(red: 0.20, green: 0.26, blue: 0.36)
}
```

| Concept | Explanation |
|---|---|
| `extension Color` | Adds new members to SwiftUI's built-in `Color` type. |
| `static let` | Lets you write `Color.brandNavy`, or just `.brandNavy` where Swift already expects a colour. |
| `Color(red:green:blue:)` | Values run from 0 to 1. To convert a hex/RGB value from a design tool, divide it by 255. |

### 4.2 `SkyBackground`

```swift
struct SkyBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.skyTop, .skyBottom], startPoint: .top, endPoint: .bottom)
            cloud(size: 70, x: 60, y: 140)
            ...
        }
        .ignoresSafeArea()
    }
}
```

- **`ZStack`** stacks views front to back. The gradient is at the back and the clouds are drawn on top.
- **`LinearGradient`** fades from one colour to another along a direction.
- **`.position(x:y:)`** places each cloud at an exact point.
- **`.ignoresSafeArea()`** lets the background run behind the status bar and home indicator so there are no white strips.

### 4.3 Reusable modifiers

```swift
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
    func outlinedBox() -> some View { modifier(OutlinedBox()) }
}
```

- A **`ViewModifier`** bundles several modifiers under one name.
- Now `.card()` gives any view the same white, rounded, shadowed card look.
- `.outlinedBox()` gives the 56pt-tall outlined input field used on Screen 2.

> **Modifier order matters.** `.padding().background()` puts the background *around* the padding. Reverse the order and the background only covers the content.

---

## 5. Step 2: Models (Sample Data)

**File:** `Models.swift`

The UI needs something to show. Models are plain Swift structs that describe that data.

### 5.1 `Account`

```swift
struct Account: Identifiable, Hashable {
    let id = UUID()
    let number: String
    let currency: String   // "USD" or "KHR"
    let type: String       // "Wallet" or "Savings"
    let balance: Double
}
```

| Part | Why |
|---|---|
| `Identifiable` + `id` | `ForEach` needs a unique ID to tell rows apart. |
| `Hashable` | Lets an account be used in selections and sets later. |
| `formattedBalance` | Uses `NumberFormatter`: USD gets 2 decimals (`58,490.25`), KHR gets none (`1,689,976`). |
| `currencyColor` | KHR shows in **gold**, USD in **navy**, matching the mock-ups. |
| `static let samples` | Four fake accounts for the list and dropdowns. |

### 5.2 `TransferSummary`

Holds everything the **Verify** and **Success** screens show: name, from/to accounts, amount, debit amount, exchange rate and reference number.

- Both screens read from `TransferSummary.sample`, so they always show the same data.
- `amountText` and `debitText` are **computed properties**. They format the numbers for display, which keeps formatting code out of the views.

---

## 6. Step 3: Reusable Components

**File:** `Components.swift`

If something appears more than once, make it a component. You write it once, and every use looks the same.

### 6.1 `HeaderBar`

```
[ ‹ ]  Transfers  ⓘ                      [logo]
```

```swift
HStack(spacing: 10) {
    Image(systemName: "chevron.left")   // back circle
    Text(title)
    if showsInfo { Image(systemName: "info.circle") }
    Spacer()                            // pushes the logo to the right edge
    Image(systemName: "building.columns.circle.fill")
}
```

- **`HStack`** lays out children left to right.
- **`Spacer()`** takes up all the free space, which pushes the logo to the far right.
- **`if showsInfo`**: the info icon only shows on Screen 1. Parameters with defaults (`var showsInfo = false`) make a component flexible.

### 6.2 `PrimaryButton`

```swift
PrimaryButton(title: "Confirm")                 // rounded (Screen 4)
PrimaryButton(title: "Ok", cornerRadius: 0)     // flat bar (Screen 2)
```

- `.frame(maxWidth: .infinity)` makes the button full width.
- A 50pt height is a comfortable tap target. Apple's minimum is 44pt.
- `action: () -> Void = {}` is an empty closure for now. You'll put navigation code in it later.

### 6.3 `InitialsAvatar`

Turns `"Narin Dev"` into `"ND"`:

```swift
name.split(separator: " ")   // ["Narin", "Dev"]
    .prefix(2)               // first two words at most
    .compactMap { $0.first } // ["N", "D"]
    .map(String.init)
    .joined()                // "ND"
```

The font size is `size * 0.38`, so the letters scale with the circle.

### 6.4 `FloatingLabel`

A small label sitting on the top border of an outlined field, like **From Account**. It has a white background that covers the border line behind it, and `.offset(x: 10, y: -7)` moves it up onto the line.

### 6.5 `FieldAccessory`

The small grey rounded square inside a field that holds **▼** (dropdown) or **i** (info).

### 6.6 `InfoRow` and `DetailRow`

| Component | Layout | Used on |
|---|---|---|
| `InfoRow` | `Label : Value` (plain text) | Screen 5 |
| `DetailRow` | `Label` + **any custom views** | Screen 4 |

`DetailRow` uses **`@ViewBuilder`**, which lets the caller pass its own views:

```swift
DetailRow(label: "Amount") {
    Text("0.02 $").font(.title3.bold()).foregroundStyle(Color.gold)
}
```

A fixed label width (`.frame(width: 95)`) lines up all the values in a neat column.

### 6.7 `DashedLine`

- `HorizontalLine` is a custom **`Shape`**. You describe a `Path` (move to the left, draw a line to the right).
- `.stroke(style: StrokeStyle(dash: [5, 4]))` draws it as 5pt dashes with 4pt gaps, like a receipt's tear line.

---

## 7. Step 4: Screen 1, Transfers Menu

**File:** `Screen1_TransferMenuView.swift`

### Layout

```
┌─────────────────────────────┐
│ HeaderBar (with ⓘ)          │
│      HeroIllustration        │  ← phone + coins
│ ╭─────────────────────────╮ │
│ │ [icon] | Own Accounts    │ │
│ │ [icon] | Bank Accounts   │ │  ← grey sheet with list
│ │ [icon] | Local       ▶   │ │
│ │ ...                      │ │
└─────────────────────────────┘
```

### How it's built

1. **The data comes first.** The five options are an array of `TransferOption` (icon, tint, title, subtitle, `hasSubmenu`).
2. **One row view, five rows.** `ForEach(options) { MenuRow(option: $0) }`. If you need to add a sixth transfer type later, you add one item to the array.
3. **`MenuRow`** is `HStack` → icon tile → thin `Rectangle` divider → title and subtitle `VStack` → `Spacer` → optional gold ▶, all wrapped in `.card()`.
4. **The grey sheet** uses `UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)`, so only the top corners are rounded.
5. **`ScrollView`** keeps the list usable on small iPhones.
6. **`HeroIllustration`** is a `ZStack` with the phone in the middle and coins moved into place with `.offset`.

> **UX note:** The gold ▶ only appears on options that open a sub-menu. It tells users that tapping leads to more choices instead of starting a transfer straight away.

---

## 8. Step 5: Screen 2, Own Accounts Form

**File:** `Screen2_OwnAccountFormView.swift`

### Layout

```
┌─────────────────────────────┐
│ HeaderBar                   │
│        [⇄]                   │  ← FeatureBadge
│     Own Accounts             │
│ ╭─────────────────────────╮ │
│ │ ┌From Account──────────┐ │ │
│ │ │   076 212 4542   [▼] │ │ │
│ │ │   1,689,976 KHR      │ │ │
│ │ └──────────────────────┘ │ │
│ │ ┌ To Account      [▼] ┐ │ │
│ │ ┌ Amount          [i] ┐ │ │
│ │  Purpose            ◯   │ │
│ │  Schedule Transfer  ◯   │ │
│ ├─────────────────────────┤ │
│ │           Ok            │ │  ← flat navy bar
└─────────────────────────────┘
```

### State: `@State` and `@Binding`

```swift
@State private var fromAccount: Account? = Account.samples[0]
@State private var toAccount: Account? = nil
@State private var amount = ""
@State private var hasPurpose = false
@State private var isScheduled = false
```

- **`@State`** is data this screen *owns*. When it changes, SwiftUI redraws the parts that use it.
- **`@Binding`** is how a child view (like `AmountField` or `ToggleRow`) reads *and writes* the parent's `@State`. Pass it with a `$`: `AmountField(amount: $amount)`.

### Components on this screen

| Component | What it does |
|---|---|
| `FeatureBadge` | Indigo rounded tile with a white border (`.overlay` + `.stroke`) and a label under it. |
| `AccountDropdown` | Has **two looks**. With no account, the label shows inside as a placeholder. With an account, the label floats up onto the border and the number and balance show on the right. |
| `AmountField` | `TextField` with `.keyboardType(.decimalPad)`, so only numbers can be typed. |
| `ToggleRow` | A system `Toggle` tinted navy. |
| "Ok" bar | `PrimaryButton(cornerRadius: 0)` with a navy background that also fills behind the home indicator. |

> **UX note:** The floating label means users still know which field they're looking at after it's filled. Plain placeholders disappear once there's a value.

---

## 9. Step 6: Screen 3, Select Account

**File:** `Screen3_SelectAccountView.swift`

### Layout: three layers

```swift
ZStack(alignment: .bottom) {
    OwnAccountFormView()          // 1. screen behind
    Color.black.opacity(0.45)     // 2. dimming layer
    SelectAccountSheet()          // 3. sheet at the bottom
}
```

`alignment: .bottom` places the sheet at the bottom of the screen.

### `SelectAccountSheet`

- **Title bar:** "Select Account" on a navy gradient.
- **Rows:** `ForEach(accounts)` with an `AccountRow` and a `Divider()` for each.
- **Shape:** `.clipShape(UnevenRoundedRectangle(...))` rounds only the top corners.
- **`onSelect`:** an empty closure for now. It's where you'll handle the tap when you add logic.

### `AccountRow`

```
076 212 4542                KHR
Wallet                1,689,976
```

- Two `HStack`s inside a `VStack`, with a `Spacer()` pushing the values to the right.
- Currency and balance use `account.currencyColor` (gold for KHR, navy for USD).
- `.contentShape(Rectangle())` makes the **whole row** tappable, including the empty space.

> **UX note:** Dimming the background keeps the user's place visible while making the sheet the clear focus.

---

## 10. Step 7: Screen 4, Verify Transaction

**File:** `Screen4_VerifyTransactionView.swift`

### Layout

```
┌─────────────────────────────┐
│ HeaderBar                   │
│ ╭ Please verify transaction╮│  ← translucent panel
│ │ ┌─────────────────────┐ ││
│ │ │ (ND) Narin Dev      │ ││
│ │ │ Amount    0.02 $    │ ││  ← white card
│ │ │─────────────────────│ ││
│ │ │ Transfer From ...   │ ││
│ │ │─────────────────────│ ││
│ │ │ Exchange Rate ...   │ ││
│ │ │ Debit Amount -100   │ ││
│ │ └─────────────────────┘ ││
│                             │
│ [         Confirm         ] │
└─────────────────────────────┘
```

### Key points

1. **Two layers:** a see-through white panel (`Color.white.opacity(0.4)`) holding a solid white `.card()`. The difference makes the card stand out.
2. **Computed view property:** the card is written as `private var detailsCard: some View`. This keeps `body` short and easy to read, and it's a good habit for long views.
3. **`DetailRow`** keeps all labels the same width so the values line up.
4. **`Divider()`** splits the card into sections: recipient and amount, source, then rates.
5. **`Spacer()`** before the button pushes **Confirm** to the bottom of the screen.

> **UX notes:**
> - **Visual hierarchy:** the amount is the largest and boldest text, in gold, because it's what users most need to check.
> - **Thumb zone:** the main action sits at the bottom, where it's easiest to reach one-handed.

---

## 11. Step 8: Screen 5, Success Receipt

**File:** `Screen5_SuccessView.swift`

### Layout

```
┌─────────────────────────────┐
│          My Bank            │
│            (✓)              │  ← badge overlapping card
│ ┌───────── Success ───────┐ │
│ │ (ND) Transferred to     │ │
│ │      Narin Dev  0.02 $  │ │
│ │- - - - - - - - - - - - -│ │  ← DashedLine
│ │ From Account : ...   ⌃  │ │
│ │ Account No.  : ...      │ │  ← collapsible
│ │ ...                     │ │
│ └─────────────────────────┘ │
│        [📅 Set Schedule]    │
│ [Home][Repeat][Accounts][Share]
└─────────────────────────────┘
```

### 11.1 Overlapping badge

```swift
ZStack(alignment: .top) {
    receiptCard.padding(.top, 34)   // card pushed down
    SuccessBadge()                  // badge stays at the top
}
```

The badge is 64pt tall and the card starts 34pt down, so the badge sits about half on and half off the card. Inside the card, "Success" has `.padding(.top, 38)` so it isn't covered by the badge.

### 11.2 `SuccessBadge`

Navy `Circle` + gold checkmark + a 4pt white ring (`.overlay(Circle().stroke(...))`).

### 11.3 Collapsible details

```swift
@State private var isExpanded = true

Button { isExpanded.toggle() } label: {
    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
}

if isExpanded {
    InfoRow(...)
    ...
}
```

- Tapping the chevron flips `isExpanded`, and SwiftUI shows or hides the rows.
- This is *UI state* inside one screen, not navigation, so it's included.

### 11.4 "Set Schedule" pill

A `Label` (icon + text) on a white `Capsule()` background.

### 11.5 `ActionBar`

- Four `ActionItem`s (Home, Repeat, Accounts, Share) drawn with `ForEach`.
- Each button has `.frame(maxWidth: .infinity)`, so they share the width **equally**.

> **UX notes:**
> - The large badge and "Success" confirm the result straight away.
> - The debit amount is shown in **red** because money is leaving the account.
> - Collapsing the details keeps the receipt short while leaving the full record one tap away.

---

## 12. Step 9: ContentView (Preview Gallery)

**File:** `ContentView.swift`

```swift
TabView {
    TransferMenuView()
    OwnAccountFormView()
    SelectAccountScreen()
    VerifyTransactionView()
    SuccessView()
}
.tabViewStyle(.page(indexDisplayMode: .never))
```

- `TabView` with `.page` style turns the screens into swipeable pages.
- It's only for checking the UI. Replace it with a `NavigationStack` when you add transitions.

---

## 13. SwiftUI Concepts Cheat Sheet

| Concept | What it does | Example in this project |
|---|---|---|
| `VStack` / `HStack` / `ZStack` | Lay out views vertically, horizontally, or stacked front to back | Every screen |
| `Spacer()` | Fills free space and pushes views apart | Logo to the right, button to the bottom |
| `.padding()` | Adds space around a view | Cards, fields |
| `.frame()` | Sets size; `maxWidth: .infinity` makes it full width | Buttons, rows |
| `.background()` / `.overlay()` | Draws something behind / in front of a view | Card fill / badge ring |
| `.clipShape()` | Cuts a view to a shape | Rounded sheets |
| `.offset()` / `.position()` | Moves a view by an amount / to an exact point | Floating label / clouds |
| `ForEach` | Builds a view for each item in a collection | Menu rows, account list |
| `@State` | Data a view owns that triggers a redraw when it changes | Toggles, amount, `isExpanded` |
| `@Binding` | Two-way link to a parent's `@State` | `AmountField`, `ToggleRow` |
| `@ViewBuilder` | Lets a component take custom child views | `DetailRow` |
| `ViewModifier` | Reusable bundle of modifiers | `.card()`, `.outlinedBox()` |
| `Shape` | Custom drawing with a `Path` | `HorizontalLine` |
| `Image(systemName:)` | Built-in SF Symbols icons | All icons |
| `#Preview` | Shows a view live in Xcode's Canvas | Bottom of every screen file |

---

## 14. UI/UX Principles Used

| Principle | Where you can see it |
|---|---|
| **Consistency** | One colour palette, the same header, cards and buttons on every screen |
| **Visual hierarchy** | Amounts are the biggest and boldest text on Verify and Success |
| **Colour meaning** | Gold for KHR, navy for USD, red for money leaving the account |
| **Focus** | The dimmed background on the Select Account sheet |
| **Affordance** | ▼ means a dropdown, ▶ means a sub-menu, a chevron means expandable |
| **Tap targets** | Buttons ≥ 44pt; whole rows are tappable |
| **Thumb zone** | Main actions (Ok, Confirm) at the bottom |
| **Progressive disclosure** | Collapsible receipt details |
| **Grouping** | Dividers and cards group related information |

---

## 15. Placeholders to Replace

| Placeholder | Where | How to replace |
|---|---|---|
| Bank logo (SF Symbol) | `HeaderBar` in `Components.swift` | Add your logo to **Assets.xcassets**, then use `Image("YourLogo").resizable().scaledToFit().frame(height: 28)` |
| "My Bank" text | `SuccessView` | Same as above |
| Hero phone + coins | `HeroIllustration` | Add the image to Assets and use `Image("TransferHero")` |
| Colours | `Theme.swift` | Pick the exact RGB values from your design and divide each by 255 |
| Sample data | `Models.swift` | Change `Account.samples` and `TransferSummary.sample` |

---

## 16. Troubleshooting

| Problem | Fix |
|---|---|
| `Cannot find 'UnevenRoundedRectangle' in scope` | Set Minimum Deployment to **iOS 17** |
| `#Preview` errors | Same fix: needs iOS 17 / Xcode 15 or later |
| `Invalid redeclaration of 'ContentView'` | Delete the `ContentView.swift` Xcode generated |
| Canvas says "Preview paused" | Press **⌥⌘P** to resume |
| White strips at the top or bottom | Check that `SkyBackground` still has `.ignoresSafeArea()` |
| An SF Symbol doesn't show | Look up the name in the free **SF Symbols** app from Apple. Some names need a newer iOS |

---

## 17. Next Steps

When the UI is approved and you're ready for behaviour:

1. **Navigation:** replace the `TabView` in `ContentView` with a `NavigationStack` and use `NavigationLink` / `navigationDestination` to move between screens.
2. **Real sheet:** show `SelectAccountSheet` with `.sheet(isPresented:)` and `.presentationDetents([.medium])` instead of the manual `ZStack`.
3. **Selection:** use the `onSelect` closure to update `fromAccount` / `toAccount`.
4. **Validation:** turn the **Ok** button off while the amount is empty or the two accounts are the same.
5. **Shared state:** move form data into an `@Observable` view model so Verify and Success show what the user actually entered.
