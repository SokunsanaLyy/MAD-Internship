import UIKit

// Reusable UIKit views used on several screens.
//
// UIKit pattern used everywhere here:
//   1. Create the subviews as properties.
//   2. In init: style them, add them (addSubview / UIStackView), and position them with constraints.
//   3. Expose a `configure(...)` method or closures (onTap, onChange) for the screen to use.

// MARK: - Header bar
// Back button + title (+ optional info icon) + logo. Taps are reported through closures.
final class HeaderBarView: UIView {

    var onBack: (() -> Void)?
    var onInfo: (() -> Void)?

    init(title: String, showsBack: Bool = true, showsInfo: Bool = false) {
        super.init(frame: .zero)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10

        if showsBack {
            let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(systemName: "chevron.left",
                                        withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
                                for: .normal)
            backButton.tintColor = .white
            backButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
            backButton.layer.cornerRadius = 18
            backButton.accessibilityLabel = "Back"
            backButton.addAction(UIAction { [weak self] _ in self?.onBack?() }, for: .touchUpInside)
            backButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                backButton.widthAnchor.constraint(equalToConstant: 36),
                backButton.heightAnchor.constraint(equalToConstant: 36)
            ])
            stack.addArrangedSubview(backButton)
        }

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .app(17, .semibold)
        titleLabel.textColor = .white
        stack.addArrangedSubview(titleLabel)

        if showsInfo {
            let infoButton = UIButton(type: .system)
            infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
            infoButton.tintColor = .white
            infoButton.accessibilityLabel = "Info"
            infoButton.addAction(UIAction { [weak self] _ in self?.onInfo?() }, for: .touchUpInside)
            stack.addArrangedSubview(infoButton)
        }

        // Spacer: stretches to push the logo to the right edge (SwiftUI: Spacer()).
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stack.addArrangedSubview(spacer)

        // Placeholder logo — swap for UIImage(named: "YourLogo").
        let logo = UIImageView(image: UIImage(systemName: "building.columns.circle.fill"))
        logo.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28)
            .applying(UIImage.SymbolConfiguration(paletteColors: [.white, .brandNavy]))
        stack.addArrangedSubview(logo)

        addSubview(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Primary button
// Navy, full width, 50pt tall. cornerRadius 0 = flat bar ("Ok"), 12 = rounded ("Confirm").
final class PrimaryButton: UIButton {

    init(title: String, cornerRadius: CGFloat = 12) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(UIColor.white.withAlphaComponent(0.8), for: .disabled)
        titleLabel?.font = .app(17, .semibold)
        backgroundColor = .brandNavy
        layer.cornerRadius = cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.45 }      // faded = can't continue yet
    }

    override var isHighlighted: Bool {
        didSet { backgroundColor = isHighlighted ? UIColor.brandNavy.withAlphaComponent(0.8) : .brandNavy }
    }
}

// MARK: - Initials avatar
// "Narin Dev" -> "ND" in a dark circle.
final class InitialsAvatarView: UILabel {

    init(name: String, size: CGFloat = 44) {
        super.init(frame: .zero)
        text = name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        font = .app(size * 0.38, .semibold)
        textColor = .white
        textAlignment = .center
        backgroundColor = .avatarGrey
        layer.cornerRadius = size / 2
        clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size),
            heightAnchor.constraint(equalToConstant: size)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Feature badge
// Rounded indigo tile with a white border and a label underneath.
final class FeatureBadgeView: UIView {

    init(icon: String, title: String) {
        super.init(frame: .zero)

        let tile = UIView()
        tile.backgroundColor = .brandIndigo
        tile.layer.cornerRadius = 16
        tile.layer.borderWidth = 2
        tile.layer.borderColor = UIColor.white.cgColor

        let iconView = UIImageView(image: UIImage(systemName: icon,
                                                  withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)))
        iconView.tintColor = .white

        let label = UILabel()
        label.text = title
        label.font = .app(12)
        label.textColor = .white

        tile.addSubviews(iconView)
        addSubviews(tile, label)
        NSLayoutConstraint.activate([
            tile.topAnchor.constraint(equalTo: topAnchor),
            tile.centerXAnchor.constraint(equalTo: centerXAnchor),
            tile.widthAnchor.constraint(equalToConstant: 60),
            tile.heightAnchor.constraint(equalToConstant: 60),
            iconView.centerXAnchor.constraint(equalTo: tile.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: tile.centerYAnchor),
            label.topAnchor.constraint(equalTo: tile.bottomAnchor, constant: 8),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Field accessory
// Small grey square holding ▼ or "i", used inside form fields.
final class FieldAccessoryView: UIView {

    init(symbol: String, tint: UIColor = .gold) {
        super.init(frame: .zero)
        backgroundColor = .surface
        layer.cornerRadius = 6
        isUserInteractionEnabled = false

        let icon = UIImageView(image: UIImage(systemName: symbol,
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)))
        icon.tintColor = tint
        addSubviews(icon)
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 32),
            heightAnchor.constraint(equalToConstant: 32),
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Outlined box
// The thin-bordered 56pt box shared by the dropdowns and the amount field.
final class OutlinedBoxView: UIView {

    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.fieldBorder.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 56).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Account dropdown
// A UIControl, so the screen can listen for taps with addAction(..., for: .touchUpInside).
// Empty: the label shows inside as a placeholder.
// Filled: the label floats on the border; number + balance show on the right.
final class AccountDropdownView: UIControl {

    private let title: String
    private let box = OutlinedBoxView()
    private let placeholderLabel = UILabel()
    private let numberLabel = UILabel()
    private let balanceLabel = UILabel()
    private let floatingLabel = UILabel()

    init(title: String) {
        self.title = title
        super.init(frame: .zero)

        // Subviews must not catch touches themselves, or the control never sees the tap.
        box.isUserInteractionEnabled = false
        floatingLabel.isUserInteractionEnabled = false

        placeholderLabel.text = title
        placeholderLabel.font = .app(15)
        placeholderLabel.textColor = .secondaryLabel

        numberLabel.font = .app(12)
        numberLabel.textColor = .secondaryLabel
        numberLabel.textAlignment = .right
        balanceLabel.font = .app(15, .semibold)
        balanceLabel.textAlignment = .right

        let valueStack = UIStackView(arrangedSubviews: [numberLabel, balanceLabel])
        valueStack.axis = .vertical
        valueStack.alignment = .trailing
        valueStack.spacing = 2

        // Floating label: white background hides the border line behind the text.
        floatingLabel.text = "  \(title)  "
        floatingLabel.font = .app(11)
        floatingLabel.textColor = .secondaryLabel
        floatingLabel.backgroundColor = .white

        let accessory = FieldAccessoryView(symbol: "arrowtriangle.down.fill")

        addSubviews(box, floatingLabel)
        box.addSubviews(placeholderLabel, valueStack, accessory)

        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: topAnchor),
            box.leadingAnchor.constraint(equalTo: leadingAnchor),
            box.trailingAnchor.constraint(equalTo: trailingAnchor),
            box.bottomAnchor.constraint(equalTo: bottomAnchor),

            accessory.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8),
            accessory.centerYAnchor.constraint(equalTo: box.centerYAnchor),

            placeholderLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            placeholderLabel.centerYAnchor.constraint(equalTo: box.centerYAnchor),

            valueStack.trailingAnchor.constraint(equalTo: accessory.leadingAnchor, constant: -8),
            valueStack.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            valueStack.leadingAnchor.constraint(greaterThanOrEqualTo: box.leadingAnchor, constant: 12),

            floatingLabel.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 8),
            floatingLabel.centerYAnchor.constraint(equalTo: box.topAnchor)
        ])

        accessibilityLabel = title
        accessibilityTraits = .button
        configure(account: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(account: Account?) {
        let filled = account != nil
        placeholderLabel.isHidden = filled
        numberLabel.isHidden = !filled
        balanceLabel.isHidden = !filled
        floatingLabel.isHidden = !filled
        if let account {
            numberLabel.text = account.number
            balanceLabel.text = "\(account.formattedBalance) \(account.currency)"
            balanceLabel.textColor = account.currencyColor
            accessibilityValue = "\(account.number), \(account.formattedBalance) \(account.currency)"
        } else {
            accessibilityValue = "Not selected"
        }
    }

    // Press feedback.
    override var isHighlighted: Bool {
        didSet { box.backgroundColor = isHighlighted ? UIColor.surface : .clear }
    }
}

// MARK: - Amount field
// Text field with a number pad, the currency on the right, and an "i" accessory.
final class AmountFieldView: UIView {

    let textField = UITextField()
    private let currencyLabel = UILabel()

    init() {
        super.init(frame: .zero)
        let box = OutlinedBoxView()

        textField.font = .app(15)
        textField.keyboardType = .decimalPad          // number pad
        textField.placeholder = "Amount"

        currencyLabel.font = .app(13)
        currencyLabel.textColor = .secondaryLabel

        let accessory = FieldAccessoryView(symbol: "info", tint: .brandNavy)

        addSubviews(box)
        box.pinEdges(to: self)
        box.addSubviews(textField, currencyLabel, accessory)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 12),
            textField.topAnchor.constraint(equalTo: box.topAnchor),
            textField.bottomAnchor.constraint(equalTo: box.bottomAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            currencyLabel.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            accessory.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 8),
            accessory.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -8),
            accessory.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])
        currencyLabel.setContentHuggingPriority(.required, for: .horizontal)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(currency: String?) {
        textField.placeholder = currency.map { "Amount (\($0))" } ?? "Amount"
        currencyLabel.text = (textField.text?.isEmpty == false) ? currency : nil
    }
}

// MARK: - Toggle row
// Title on the left, a navy switch on the right.
final class ToggleRowView: UIView {

    let toggle = UISwitch()
    var onChange: ((Bool) -> Void)?

    init(title: String) {
        super.init(frame: .zero)
        let label = UILabel()
        label.text = title
        label.font = .app(15)
        label.textColor = .brandNavy

        toggle.onTintColor = .brandNavy
        toggle.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.onChange?(self.toggle.isOn)
        }, for: .valueChanged)

        addSubviews(label, toggle)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            toggle.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggle.topAnchor.constraint(equalTo: topAnchor),
            toggle.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Info row  (Success screen)
// "Label : Value" with a fixed-width label so values line up.
final class InfoRowView: UIView {

    init(label: String, value: String, valueColor: UIColor = .label) {
        super.init(frame: .zero)
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .app(12)
        labelView.textColor = .secondaryLabel

        let colon = UILabel()
        colon.text = ":"
        colon.font = .app(12)
        colon.textColor = .secondaryLabel

        let valueView = UILabel()
        valueView.text = value
        valueView.font = .app(12)
        valueView.textColor = valueColor
        valueView.numberOfLines = 0

        addSubviews(labelView, colon, valueView)
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelView.topAnchor.constraint(equalTo: topAnchor),
            labelView.widthAnchor.constraint(equalToConstant: 100),
            colon.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 6),
            colon.topAnchor.constraint(equalTo: topAnchor),
            valueView.leadingAnchor.constraint(equalTo: colon.trailingAnchor, constant: 6),
            valueView.trailingAnchor.constraint(equalTo: trailingAnchor),
            valueView.topAnchor.constraint(equalTo: topAnchor),
            valueView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Detail row  (Verify screen)
// A label on the left and ANY content view on the right (like @ViewBuilder in SwiftUI).
final class DetailRowView: UIView {

    init(label: String, content: UIView) {
        super.init(frame: .zero)
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .app(12)
        labelView.textColor = .secondaryLabel

        addSubviews(labelView, content)
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            labelView.widthAnchor.constraint(equalToConstant: 95),
            content.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 8),
            content.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            content.topAnchor.constraint(equalTo: topAnchor),
            content.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Dashed line  (receipt "tear line")
final class DashedLineView: UIView {

    private let shape = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        shape.strokeColor = UIColor.fieldBorder.cgColor
        shape.lineWidth = 1
        shape.lineDashPattern = [5, 4]           // 5pt dash, 4pt gap
        layer.addSublayer(shape)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Redraw whenever the view's width changes (e.g. rotation).
    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: bounds.midY))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        shape.path = path.cgPath
    }
}

// MARK: - Helpers for building labels and dividers quickly
extension UILabel {
    static func make(_ text: String? = nil, size: CGFloat, weight: UIFont.Weight = .regular,
                     color: UIColor = .label, lines: Int = 1) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .app(size, weight)
        label.textColor = color
        label.numberOfLines = lines
        return label
    }
}

extension UIView {
    static func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = .fieldBorder
        line.translatesAutoresizingMaskIntoConstraints = false
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }
}
