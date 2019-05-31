// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StackViewController
import Result
import SafariServices

protocol TransactionViewControllerDelegate: class, CanOpenURL {
}

class TransactionViewController: UIViewController {
    private lazy var viewModel: TransactionDetailsViewModel = {
        return .init(
            transaction: transaction,
            chainState: session.chainState,
            currentWallet: session.account,
            currencyRate: session.balanceCoordinator.currencyRate
        )
    }()
    private let stackViewController = StackViewController()
    private let session: WalletSession
    private let transaction: Transaction

    weak var delegate: TransactionViewControllerDelegate?

    init(
        session: WalletSession,
        transaction: Transaction,
        delegate: TransactionViewControllerDelegate?
    ) {
        self.session = session
        self.transaction = transaction
        self.delegate = delegate

        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.stackView.spacing = 10

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let header = TransactionHeaderView(server: session.server)
        header.translatesAutoresizingMaskIntoConstraints = false
        header.configure(amount: viewModel.amountAttributedString)

        var items: [UIView] = [
            .spacer(),
            header,
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            item(title: viewModel.fromLabelTitle, value: viewModel.from),
            item(title: viewModel.toLabelTitle, value: viewModel.to),
            item(title: viewModel.gasFeeLabelTitle, value: viewModel.gasFee),
            item(title: viewModel.confirmationLabelTitle, value: viewModel.confirmation),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            item(title: viewModel.transactionIDLabelTitle, value: viewModel.transactionID),
            item(title: viewModel.createdAtLabelTitle, value: viewModel.createdAt),
            item(title: viewModel.blockNumberLabelTitle, value: viewModel.blockNumber),
        ]

        if viewModel.detailsAvailable {
            items.append(moreDetails())
        }

        for item in items {
            stackViewController.addItem(item)
        }

        displayChildViewController(viewController: stackViewController)

        if viewModel.shareAvailable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        }
    }

    private func item(title: String, value: String) -> UIView {
        return  TransactionAppearance.item(
            title: title,
            subTitle: value
        ) { [weak self] in
            self?.showAlertSheet(title: $0, value: $1, sourceView: $2)
        }
    }

    private func moreDetails() -> UIView {
        let button = Button(size: .large, style: .border)
        button.setTitle(R.string.localizable.moreDetails(), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(more), for: .touchUpInside)

        let stackView = [button].asStackView(spacing: 10)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }

    func showAlertSheet(title: String, value: String, sourceView: UIView) {
        let alertController = UIAlertController(
            title: nil,
            message: value,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        let copyAction = UIAlertAction(title: R.string.localizable.copy(), style: .default) { _ in
            UIPasteboard.general.string = value
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in }
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func more() {
        guard let url = viewModel.detailsURL else { return }
        delegate?.didPressOpenWebPage(url, in: self)
    }

    @objc func share(_ sender: UIBarButtonItem) {
        guard let item = viewModel.shareItem else { return }
        let activityViewController = UIActivityViewController(
            activityItems: [
                item,
            ],
            applicationActivities: nil
        )
        activityViewController.popoverPresentationController?.barButtonItem = sender
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func dismiss() {
        dismiss(animated: true, completion: nil)
    }
}
