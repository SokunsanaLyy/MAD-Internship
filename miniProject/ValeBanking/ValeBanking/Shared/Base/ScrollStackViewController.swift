//
//  ScrollStackViewController.swift
//  ValeBanking
//
//  Created by Sokunsana Ly on 3/11/2026.
//

import UIKit

// MARK: - ScrollStackViewController

class ScrollStackViewController: UIViewController {

    let scrollView = UIScrollView()
    let contentStack = UIStackView(axis: .vertical, spacing: AppLayout.sectionSpacing)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .valeBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive

        view.addSubviews(scrollView)
        scrollView.addSubviews(contentStack)

        let padding = AppLayout.screenPadding
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 12),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: padding),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -padding)
        ])
    }
}
