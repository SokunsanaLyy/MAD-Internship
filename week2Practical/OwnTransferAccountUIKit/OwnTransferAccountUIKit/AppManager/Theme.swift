import UIKit

// MARK: - Colours
// One place for every colour in the app. Change a value here and every screen updates.
extension UIColor {
    static let brandNavy   = UIColor(red: 0.06, green: 0.20, blue: 0.47, alpha: 1)  // buttons, titles, USD
    static let brandIndigo = UIColor(red: 0.29, green: 0.30, blue: 0.62, alpha: 1)  // icon tiles
    static let skyTop      = UIColor(red: 0.23, green: 0.47, blue: 0.80, alpha: 1)  // background top
    static let skyBottom   = UIColor(red: 0.62, green: 0.80, blue: 0.96, alpha: 1)  // background bottom
    static let gold        = UIColor(red: 0.82, green: 0.62, blue: 0.13, alpha: 1)  // KHR amounts, arrows
    static let debitRed    = UIColor(red: 0.80, green: 0.10, blue: 0.10, alpha: 1)  // money leaving
    static let fieldBorder = UIColor.gray.withAlphaComponent(0.25)                  // outlines, dividers
    static let surface     = UIColor.systemGray6                                    // light grey panels
    static let avatarGrey  = UIColor(red: 0.20, green: 0.26, blue: 0.36, alpha: 1)
}

// MARK: - Reusable view helpers
extension UIView {

    /// White card with rounded corners and a soft shadow (SwiftUI: .card()).
    func applyCardStyle(cornerRadius: CGFloat = 14) {
        backgroundColor = .white
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }

    /// Rounds only the top-left and top-right corners (for bottom sheets).
    func roundTopCorners(_ radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    /// Pins this view to all four edges of another view.
    func pinEdges(to other: UIView, insets: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }

    /// Adds several subviews and switches them all to Auto Layout.
    func addSubviews(_ views: UIView...) {
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
    }
}

// MARK: - Fonts
extension UIFont {
    static func app(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}

// MARK: - Sky background
// A view whose own layer IS a gradient, plus three clouds. Used behind every screen.
final class SkyBackgroundView: UIView {

    override class var layerClass: AnyClass { CAGradientLayer.self }
    private var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.skyTop.cgColor, UIColor.skyBottom.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        isUserInteractionEnabled = false          // decoration only — never blocks taps

        addCloud(size: 70, x: 60, y: 140)
        addCloud(size: 50, x: 320, y: 110)
        addCloud(size: 40, x: 250, y: 190)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func addCloud(size: CGFloat, x: CGFloat, y: CGFloat) {
        let cloud = UIImageView(image: UIImage(systemName: "cloud.fill",
                                               withConfiguration: UIImage.SymbolConfiguration(pointSize: size)))
        cloud.tintColor = UIColor.white.withAlphaComponent(0.55)
        addSubviews(cloud)
        NSLayoutConstraint.activate([
            cloud.centerXAnchor.constraint(equalTo: leadingAnchor, constant: x),
            cloud.centerYAnchor.constraint(equalTo: topAnchor, constant: y)
        ])
    }
}

// MARK: - BaseViewController
// Every screen inherits from this, so they all get the sky background,
// white status bar text, and a simple way to show a message.
class BaseViewController: UIViewController {

    let background = SkyBackgroundView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .skyBottom
        view.addSubview(background)
        background.pinEdges(to: view)            // fills the screen, behind the status bar too
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    /// UIKit has no "toast", so short messages use an alert.
    func showMessage(_ text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
