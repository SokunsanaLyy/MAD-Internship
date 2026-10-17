import UIKit

// MARK: - UIControl
extension UIControl {
    /// Shortcut for actions:
    ///   button.on(.touchUpInside) { … }
    /// instead of
    ///   button.addAction(UIAction { _ in … }, for: .touchUpInside)
    func on(_ event: UIControl.Event, _ action: @escaping () -> Void) {
        addAction(UIAction { _ in action() }, for: event)
    }
}

// MARK: - UIView
extension UIView {
    /// Leading + trailing constraints to another view (not activated yet).
    /// Use inside NSLayoutConstraint.activate([...] + view.horizontalConstraints(to: other)).
    func horizontalConstraints(to other: UIView, inset: CGFloat = 0) -> [NSLayoutConstraint] {
        [leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: inset),
         trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -inset)]
    }
}
