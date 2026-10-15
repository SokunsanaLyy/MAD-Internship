import UIKit

// SCREEN 3 — Select Account
// A real iOS bottom sheet. It slides up over the form, dims the form behind it,
// and closes when the user picks an account, swipes it down, or taps outside it.
//
// Also reused read-only by "Accounts" on the Success screen (onSelect = nil).

final class SelectAccountViewController: UIViewController {

    private let sheetTitle: String
    private let accounts: [Account]
    private let selectedID: UUID?
    private let onSelect: ((Account) -> Void)?
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(title: String, accounts: [Account], selectedID: UUID?, onSelect: ((Account) -> Void)?) {
        self.sheetTitle = title
        self.accounts = accounts
        self.selectedID = selectedID
        self.onSelect = onSelect
        super.init(nibName: nil, bundle: nil)

        // Present as a sheet: half height first, can be dragged up to full height.
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.preferredCornerRadius = 20
            sheet.prefersGrabberVisible = false        // our navy title bar replaces the grabber
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .surface

        // Navy title bar with a gradient.
        let titleBar = GradientTitleBar(title: sheetTitle)

        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.separatorColor = .fieldBorder
        tableView.separatorInset = .zero
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = onSelect != nil       // read-only when there's nothing to pick
        tableView.register(AccountCell.self, forCellReuseIdentifier: AccountCell.reuseID)

        view.addSubviews(titleBar, tableView)
        NSLayoutConstraint.activate([
            titleBar.topAnchor.constraint(equalTo: view.topAnchor),
            titleBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleBar.heightAnchor.constraint(equalToConstant: 52),

            tableView.topAnchor.constraint(equalTo: titleBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension SelectAccountViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accounts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseID, for: indexPath) as! AccountCell
        let account = accounts[indexPath.row]
        cell.configure(with: account, isSelected: account.id == selectedID)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        onSelect?(account)            // tell the form which account was chosen
        dismiss(animated: true)       // close the sheet
    }
}

// MARK: - Gradient title bar
final class GradientTitleBar: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }

    init(title: String) {
        super.init(frame: .zero)
        let gradient = layer as! CAGradientLayer
        gradient.colors = [UIColor.brandNavy.withAlphaComponent(0.8).cgColor, UIColor.brandNavy.cgColor]

        let label = UILabel.make(title, size: 17, weight: .semibold, color: .white)
        addSubviews(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Account cell
// Two lines: number + currency / type + balance. A gold tick marks the current choice.
final class AccountCell: UITableViewCell {

    static let reuseID = "AccountCell"

    private let numberLabel = UILabel.make(size: 15, weight: .medium, color: .brandNavy)
    private let currencyLabel = UILabel.make(size: 12, weight: .bold)
    private let typeLabel = UILabel.make(size: 12, color: .secondaryLabel)
    private let balanceLabel = UILabel.make(size: 15, weight: .semibold)
    private let checkView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        checkView.tintColor = .gold
        currencyLabel.textAlignment = .right
        balanceLabel.textAlignment = .right

        let topRow = UIStackView(arrangedSubviews: [numberLabel, currencyLabel])
        let bottomRow = UIStackView(arrangedSubviews: [typeLabel, balanceLabel])
        [topRow, bottomRow].forEach { $0.axis = .horizontal; $0.distribution = .fill }
        numberLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        typeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let textStack = UIStackView(arrangedSubviews: [topRow, bottomRow])
        textStack.axis = .vertical
        textStack.spacing = 6

        let row = UIStackView(arrangedSubviews: [textStack, checkView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        contentView.addSubview(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with account: Account, isSelected: Bool) {
        numberLabel.text = account.number
        currencyLabel.text = account.currency
        currencyLabel.textColor = account.currencyColor
        typeLabel.text = account.type
        balanceLabel.text = account.formattedBalance
        balanceLabel.textColor = account.currencyColor
        checkView.isHidden = !isSelected
        backgroundColor = isSelected ? UIColor.brandNavy.withAlphaComponent(0.06) : .clear
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}
