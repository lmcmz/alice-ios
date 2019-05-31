// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

class PeekOpenSeaNonFungibleTokenViewController: UIViewController {
    private let tokenRowView = OpenSeaNonFungibleTokenCardRowView()
    private let scrollView = UIScrollView()
    let indexPath: IndexPath

    init(forIndexPath indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(tokenRowView)
        view.addSubview(scrollView)

        tokenRowView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tokenRowView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            tokenRowView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            tokenRowView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            //Using trailingAnchor doesn't work correctly. The width width of the child is too narrow. So we use widthAnchor
            tokenRowView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: OpenSeaNonFungibleTokenCardRowViewModel) {
        view.backgroundColor = .white

        tokenRowView.configure(viewModel: viewModel)

        tokenRowView.stateLabel.isHidden = true
    }
}
