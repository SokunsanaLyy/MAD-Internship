import UIKit

// UIKit versions of the reusable pieces from Theme.swift and Components.swift.
//
// The big difference from SwiftUI:
//  • SwiftUI: DESCRIBE the screen, SwiftUI builds and updates it.
//  • UIKit:   CREATE each view object, ADD it to a parent, and POSITION it with
//             Auto Layout constraints. When data changes, you update the views yourself.

// MARK: - Card style  (SwiftUI: .card())
extension UIView {
    /// White background, rounded corners and a soft shadow.
    func applyCardStyle(cornerRadius: CGFloat = 14) {
        backgroundColor = .white
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    /// Pins this view to all four edges of another view (used a lot, so it's a helper).
    func pinEdges(to other: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }
}

// MARK: - Sky background  (SwiftUI: SkyBackground)
// A view whose own layer IS a gradient, plus three cloud icons.
final class SkyBackgroundView: UIView {

    // Tell UIKit to use a CAGradientLayer as this view's main layer.
    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.skyTop.cgColor, UIColor.skyBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)

        addCloud(size: 70, x: 60, y: 140)
        addCloud(size: 50, x: 320, y: 110)
        addCloud(size: 40, x: 250, y: 190)
    }

    // Required by UIKit for views loaded from storyboards. We build in code, so it's unused.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func addCloud(size: CGFloat, x: CGFloat, y: CGFloat) {
        let cloud = UIImageView(image: UIImage(systemName: "cloud.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: size)))
        cloud.tintColor = UIColor.white.withAlphaComponent(0.55)
        cloud.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cloud)
        NSLayoutConstraint.activate([
            cloud.centerXAnchor.constraint(equalTo: leadingAnchor, constant: x),
            cloud.centerYAnchor.constraint(equalTo: topAnchor, constant: y)
        ])
    }
}

// MARK: - Header bar  (SwiftUI: HeaderBar — renamed so both can exist during the migration)
// Back button + title (+ optional info icon) + logo.
// Taps are reported through closures; the view controller decides what they do.
final class HeaderBarView: UIView {

    var onBack: (() -> Void)?
    var onInfo: (() -> Void)?

    init(title: String, showsInfo: Bool = false) {
        super.init(frame: .zero)

        // Back button: white chevron in a translucent circle, 36pt so it's easy to tap.
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(systemName: "chevron.left",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)),
                            for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor.white.withAlphaComponent(0.25)
        backButton.layer.cornerRadius = 18
        backButton.accessibilityLabel = "Back"
        backButton.addAction(UIAction { [weak self] _ in self?.onBack?() }, for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .white

        let stack = UIStackView(arrangedSubviews: [backButton, titleLabel])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10

        if showsInfo {
            let infoButton = UIButton(type: .system)
            infoButton.setImage(UIImage(systemName: "info.circle"), for: .normal)
            infoButton.tintColor = .white
            infoButton.accessibilityLabel = "Info"
            infoButton.addAction(UIAction { [weak self] _ in self?.onInfo?() }, for: .touchUpInside)
            stack.addArrangedSubview(infoButton)
        }

        // Spacer: an empty view that stretches, pushing the logo to the right (SwiftUI: Spacer()).
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
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - Primary button  (SwiftUI: PrimaryButton — renamed so both can exist during the migration)
// Navy, full width, 50pt tall. cornerRadius 0 = flat bar ("Ok"), 12 = rounded ("Confirm").
final class PrimaryActionButton: UIButton {

    init(title: String, cornerRadius: CGFloat = 12) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .preferredFont(forTextStyle: .headline)
        backgroundColor = .brandNavy
        layer.cornerRadius = cornerRadius
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Fades the button when disabled (used later by the form's "Ok").
    override var isEnabled: Bool {
        didSet { alpha = isEnabled ? 1 : 0.45 }
    }
}

// MARK: - Initials avatar  (SwiftUI: InitialsAvatar)
// "Sokusana Ly" -> "SL" in a dark circle. Used later by Verify and Success.
final class InitialsAvatarView: UILabel {

    init(name: String, size: CGFloat = 44) {
        super.init(frame: .zero)
        text = name.split(separator: " ").prefix(2).compactMap { $0.first }.map(String.init).joined()
        font = .systemFont(ofSize: size * 0.38, weight: .semibold)
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
