import UIKit
import SwiftUI   // only for the temporary bridge to the SwiftUI form (see openOwnAccounts)

// SCREEN 1 — Transfers menu, in UIKit.
//
// SwiftUI → UIKit mapping used here:
//   struct TransferMenuView: View      → class TransferMenuViewController: UIViewController
//   ZStack / VStack                    → addSubview + Auto Layout constraints
//   ScrollView + ForEach(MenuRow)      → UITableView + MenuCell (reusable rows)
//   .onTapGesture / Button             → UITableViewDelegate didSelectRowAt

// One row's data. (Called MenuOption so it doesn't clash with SwiftUI's TransferOption.)
struct MenuOption {
    let icon: String
    let tint: UIColor
    let title: String
    let subtitle: String
    let hasSubmenu: Bool
}

final class TransferMenuViewController: UIViewController {

    private let options: [MenuOption] = [
        MenuOption(icon: "arrow.left.arrow.right", tint: .brandIndigo, title: "Own Accounts",
                   subtitle: "Own account transfers", hasSubmenu: false),
        MenuOption(icon: "person.2.fill", tint: .brandNavy, title: "Bank Accounts | Phone",
                   subtitle: "Transfer to bank accounts | phone numbers", hasSubmenu: false),
        MenuOption(icon: "building.columns.fill", tint: .systemPurple, title: "Local Transfers",
                   subtitle: "Transfer to banks | MFIs | wallets", hasSubmenu: true),
        MenuOption(icon: "globe.asia.australia.fill", tint: .systemTeal, title: "International Transfers",
                   subtitle: "Transfer worldwide to banks | agents", hasSubmenu: true),
        MenuOption(icon: "creditcard.fill", tint: .systemPink, title: "Card Transfers",
                   subtitle: "Transfer to other bank cards", hasSubmenu: true)
    ]

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: Lifecycle
    // viewDidLoad runs ONCE, when the screen's view is first created: build the UI here.
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLayout()
    }

    // viewWillAppear runs EVERY time the screen is about to show (including after Back).
    // We draw our own header, so we hide the system navigation bar on this screen.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: Layout
    private func buildLayout() {
        let background = SkyBackgroundView()

        let header = HeaderBarView(title: "Transfers", showsInfo: true)
        header.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        header.onInfo = { [weak self] in self?.showMessage("Move money between your accounts or to others.") }

        let hero = HeroIllustrationView()

        // Grey sheet with only the TOP corners rounded (SwiftUI: UnevenRoundedRectangle).
        let sheet = UIView()
        sheet.backgroundColor = .surface
        sheet.layer.cornerRadius = 24
        sheet.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)

        // Add views. Later ones are drawn on top (like a ZStack).
        [background, header, hero, sheet].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false   // position with constraints
            view.addSubview($0)
        }
        sheet.addSubview(tableView)
        tableView.pinEdges(to: sheet)
        background.pinEdges(to: view)                               // fills the screen, under the status bar

        NSLayoutConstraint.activate([
            // Header sits just below the status bar / notch.
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            hero.topAnchor.constraint(equalTo: header.bottomAnchor),
            hero.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hero.widthAnchor.constraint(equalToConstant: 200),
            hero.heightAnchor.constraint(equalToConstant: 150),

            // Sheet fills the rest, down past the home indicator.
            sheet.topAnchor.constraint(equalTo: hero.bottomAnchor),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: Actions

    private func openOwnAccounts() {
        // TEMPORARY BRIDGE: the form isn't converted to UIKit yet, so we show the existing
        // SwiftUI screen inside a UIHostingController. This lets you migrate one screen at a
        // time while the app keeps working. Replace this with the UIKit form in the next step.
        let form = UIHostingController(rootView: OwnAccountFormView())
        navigationController?.setNavigationBarHidden(false, animated: true)   // gives a working Back button for now
        navigationController?.pushViewController(form, animated: true)
    }

    // UIKit has no Toast, so a simple alert is used for messages.
    private func showMessage(_ text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Table view data source & delegate
// A UITableView asks its dataSource "how many rows?" and "what cell for row N?",
// and tells its delegate "row N was tapped".
extension TransferMenuViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cells are RECYCLED as you scroll: dequeue gives back a used one to fill with new data.
        let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.reuseID, for: indexPath) as! MenuCell
        cell.configure(with: options[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = options[indexPath.row]
        if option.title == "Own Accounts" {
            openOwnAccounts()
        } else {
            showMessage("\(option.title) is coming soon.")
        }
    }
}

// MARK: - Menu cell  (SwiftUI: MenuRow)
// Card with: icon tile | divider | title + subtitle | optional gold arrow.
final class MenuCell: UITableViewCell {

    static let reuseID = "MenuCell"

    private let card = UIView()
    private let iconTile = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let arrowView = UIImageView(image: UIImage(systemName: "arrowtriangle.right.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none          // show our own press effect instead of grey highlight

        card.applyCardStyle()

        iconTile.layer.cornerRadius = 9
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        let divider = UIView()
        divider.backgroundColor = .fieldBorder

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .brandNavy
        subtitleLabel.font = .preferredFont(forTextStyle: .caption1)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        arrowView.tintColor = .gold
        arrowView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [iconTile, divider, textStack, arrowView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        iconTile.addSubview(iconView)
        contentView.addSubview(card)
        card.addSubview(row)
        [iconTile, iconView, divider, card, row].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        // 5pt above + 5pt below each card = 10pt gap between cards.
        card.pinEdges(to: contentView, insets: UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16))
        row.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        NSLayoutConstraint.activate([
            iconTile.widthAnchor.constraint(equalToConstant: 34),
            iconTile.heightAnchor.constraint(equalToConstant: 34),
            iconView.centerXAnchor.constraint(equalTo: iconTile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconTile.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with option: MenuOption) {
        iconTile.backgroundColor = option.tint
        iconView.image = UIImage(systemName: option.icon)
        titleLabel.text = option.title
        subtitleLabel.text = option.subtitle
        arrowView.isHidden = !option.hasSubmenu    // hidden views drop out of a UIStackView
    }

    // Press feedback: the card dims while your finger is on it.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) { self.card.alpha = highlighted ? 0.6 : 1 }
    }
}

// MARK: - Hero illustration  (SwiftUI: HeroIllustration)
// Phone + floating coins, placed with centre offsets.
final class HeroIllustrationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        let phone = UIImageView(image: UIImage(systemName: "iphone.gen3",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 80)))
        phone.tintColor = .white
        phone.transform = CGAffineTransform(rotationAngle: -15 * .pi / 180)
        place(phone, x: 0, y: 0)

        let coins: [(x: CGFloat, y: CGFloat, size: CGFloat)] = [
            (-60, -30, 26), (55, -45, 30), (62, 25, 22), (-50, 38, 20), (15, -62, 18)
        ]
        for coin in coins {
            let config = UIImage.SymbolConfiguration(pointSize: coin.size)
                .applying(UIImage.SymbolConfiguration(paletteColors: [.white, .gold]))
            place(UIImageView(image: UIImage(systemName: "dollarsign.circle.fill", withConfiguration: config)),
                  x: coin.x, y: coin.y)
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Centre a subview, shifted by (x, y) — SwiftUI's .offset(x:y:).
    private func place(_ subview: UIView, x: CGFloat, y: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor, constant: x),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor, constant: y)
        ])
    }
}
