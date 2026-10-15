import UIKit

// SCREEN 1 — Transfers menu
// Layout: sky background → header → illustration → grey sheet with a table of cards.
//
// SwiftUI → UIKit:
//   ScrollView + ForEach(MenuRow) → UITableView + MenuCell (rows are recycled while scrolling)
//   tap on a row                  → UITableViewDelegate.didSelectRowAt

struct MenuOption {
    let icon: String
    let tint: UIColor
    let title: String
    let subtitle: String
    let hasSubmenu: Bool
}

final class TransferMenuViewController: BaseViewController {

    private let store: TransferStore
    private let tableView = UITableView(frame: .zero, style: .plain)

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

    // The store is passed in ("dependency injection"), so every screen shares the same one.
    init(store: TransferStore) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // viewDidLoad runs once, when the screen is first created: build the UI here.
    override func viewDidLoad() {
        super.viewDidLoad()

        // The first screen has nothing to go back to, so the back button is hidden.
        // (iOS apps don't close themselves — users go Home with the system gesture.)
        let header = HeaderBarView(title: "Transfers", showsBack: false, showsInfo: true)
        header.onInfo = { [weak self] in self?.showMessage("Move money between your own accounts or to others.") }

        let hero = HeroIllustrationView()

        let sheet = UIView()
        sheet.backgroundColor = .surface
        sheet.roundTopCorners(24)

        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 11, left: 0, bottom: 11, right: 0)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuCell.self, forCellReuseIdentifier: MenuCell.reuseID)

        view.addSubviews(header, hero, sheet)
        sheet.addSubview(tableView)
        tableView.pinEdges(to: sheet)

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            hero.topAnchor.constraint(equalTo: header.bottomAnchor),
            hero.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hero.widthAnchor.constraint(equalToConstant: 200),
            hero.heightAnchor.constraint(equalToConstant: 150),

            sheet.topAnchor.constraint(equalTo: hero.bottomAnchor),
            sheet.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sheet.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sheet.bottomAnchor.constraint(equalTo: view.bottomAnchor)   // runs under the home indicator
        ])
    }

    private func openOwnAccounts() {
        store.startNew()                                                // fresh form every time
        let form = OwnAccountFormViewController(store: store)
        navigationController?.pushViewController(form, animated: true)  // push = go forward
    }
}

// MARK: - Table view
// The table asks its dataSource "how many rows?" and "which cell for row N?",
// and tells its delegate "row N was tapped".
extension TransferMenuViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

// MARK: - Menu cell
// Card: icon tile | divider | title + subtitle | optional gold arrow.
final class MenuCell: UITableViewCell {

    static let reuseID = "MenuCell"

    private let card = UIView()
    private let iconTile = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel.make(size: 15, weight: .semibold, color: .brandNavy)
    private let subtitleLabel = UILabel.make(size: 12, color: .secondaryLabel, lines: 0)
    private let arrowView = UIImageView(image: UIImage(systemName: "arrowtriangle.right.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none                 // we show our own press effect

        card.applyCardStyle()
        iconTile.layer.cornerRadius = 9
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        arrowView.tintColor = .gold
        arrowView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 10)

        let divider = UIView()
        divider.backgroundColor = .fieldBorder

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [iconTile, divider, textStack, arrowView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        iconTile.addSubviews(iconView)
        contentView.addSubview(card)
        card.addSubview(row)
        card.pinEdges(to: contentView, insets: UIEdgeInsets(top: 5, left: 16, bottom: 5, right: 16))
        row.pinEdges(to: card, insets: UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14))

        [iconTile, divider].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
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
        arrowView.isHidden = !option.hasSubmenu
    }

    // The card dims while a finger is on it.
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.15) { self.card.alpha = highlighted ? 0.6 : 1 }
    }
}

// MARK: - Hero illustration
// Phone + floating coins placed with centre offsets.
final class HeroIllustrationView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false

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

    private func place(_ subview: UIView, x: CGFloat, y: CGFloat) {
        addSubviews(subview)
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor, constant: x),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor, constant: y)
        ])
    }
}
