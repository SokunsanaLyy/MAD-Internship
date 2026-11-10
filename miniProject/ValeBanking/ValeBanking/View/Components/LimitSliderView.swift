//
//  LimitSliderView.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 10/11/2026.
//

import UIKit

final class LimitSliderView: UIView {

    var onChange: ((Double) -> Void)?

    private let step: Double
    private let titleLabel = UILabel(font: .vale(15, .semibold))
    private let captionLabel = UILabel(font: .vale(13), color: .valeMuted, lines: 0)
    private let valueLabel = UILabel(font: .vale(32, .medium))
    private let slider = UISlider()
    private let minLabel = UILabel(font: .vale(12), color: .valeMuted)
    private let maxLabel = UILabel(font: .vale(12), color: .valeMuted)

    init(title: String, caption: String, range: ClosedRange<Double>, step: Double) {
        self.step = step
        super.init(frame: .zero)
        titleLabel.text = title
        captionLabel.text = caption
        slider.minimumValue = Float(range.lowerBound)
        slider.maximumValue = Float(range.upperBound)
        minLabel.text = Format.money(range.lowerBound).replacingOccurrences(of: ".00", with: "")
        maxLabel.text = Format.money(range.upperBound).replacingOccurrences(of: ".00", with: "")
        slider.accessibilityLabel = title
        setupViews()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setValue(_ value: Double) {
        slider.value = Float(value)
        render(value)
    }

    private func setupViews() {
        applyCardStyle()
        slider.minimumTrackTintColor = .valeInk
        slider.maximumTrackTintColor = .valeBorder
        slider.thumbTintColor = .valeLime

        let ends = UIStackView(axis: .horizontal, views: [minLabel, .spacer(), maxLabel])
        let stack = UIStackView(axis: .vertical, spacing: 8,
                                views: [titleLabel, captionLabel, valueLabel, slider, ends])
        stack.setCustomSpacing(14, after: captionLabel)
        stack.setCustomSpacing(4, after: slider)
        addSubviews(stack)
        stack.pinEdges(to: self, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }

    private func setupActions() {
        slider.on(.valueChanged) { [weak self] in
            guard let self else { return }
            let snapped = (Double(self.slider.value) / self.step).rounded() * self.step
            self.slider.value = Float(snapped)
            self.render(snapped)
            self.onChange?(snapped)
        }
    }

    private func render(_ value: Double) {
        valueLabel.text = Format.money(value).replacingOccurrences(of: ".00", with: "")
        slider.accessibilityValue = valueLabel.text
    }
}
