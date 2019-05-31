// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

protocol ConfirmSignMessageViewControllerDelegate: class {
    func didPressProceed(in viewController: ConfirmSignMessageViewController)
    func didPressCancel(in viewController: ConfirmSignMessageViewController)
}

//TODO make more reusable as an alert?
class ConfirmSignMessageViewController: UIViewController {
    private let background = UIView()
	private let header = TokensCardViewControllerTitleHeader()
    private let detailsBackground = UIView()
    private let singleMessageLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let actionButton = UIButton()
    private let cancelButton = UIButton()
    private var viewModel: ConfirmSignMessageViewControllerViewModel?
    lazy private var tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
    private var tableViewContentSizeObserver: NSKeyValueObservation?

    weak var delegate: ConfirmSignMessageViewControllerDelegate?

    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear

        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(visualEffectView, at: 0)

        view.addSubview(background)
        background.translatesAutoresizingMaskIntoConstraints = false

        singleMessageLabel.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(ConfirmSignMessageTableViewCell.self, forCellReuseIdentifier: ConfirmSignMessageTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.separatorStyle = .none

        detailsBackground.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(detailsBackground)

        actionButton.addTarget(self, action: #selector(proceed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)

        let stackView = [
			header,
            .spacer(height: 20),
            tableView,
            singleMessageLabel,
            .spacer(height: 30),
            actionButton,
            .spacer(height: 10),
            cancelButton,
            .spacer(height: 1)
        ].asStackView(axis: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        background.addSubview(stackView)

        tableView.isScrollEnabled = false
        NSLayoutConstraint.activate([
            header.heightAnchor.constraint(equalToConstant: 60),
            //Strange repositioning of header horizontally while typing without this
            header.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            detailsBackground.leadingAnchor.constraint(equalTo: background.leadingAnchor),
            detailsBackground.trailingAnchor.constraint(equalTo: background.trailingAnchor),
            detailsBackground.topAnchor.constraint(lessThanOrEqualTo: singleMessageLabel.topAnchor, constant: -12),
            detailsBackground.bottomAnchor.constraint(greaterThanOrEqualTo: singleMessageLabel.bottomAnchor, constant: 12),
            detailsBackground.topAnchor.constraint(lessThanOrEqualTo: tableView.topAnchor, constant: -12),
            detailsBackground.bottomAnchor.constraint(greaterThanOrEqualTo: tableView.bottomAnchor, constant: 12),

            tableViewHeightConstraint,

            actionButton.heightAnchor.constraint(equalToConstant: 47),
            cancelButton.heightAnchor.constraint(equalTo: actionButton.heightAnchor),

            stackView.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: -30),
            stackView.topAnchor.constraint(equalTo: background.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: background.bottomAnchor, constant: -16),

            background.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 42),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -42),
            background.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: ConfirmSignMessageViewControllerViewModel) {
        self.viewModel = viewModel
        if let viewModel = self.viewModel {
            background.backgroundColor = viewModel.contentsBackgroundColor
            background.layer.cornerRadius = 20

            header.configure(title: viewModel.headerTitle)

            singleMessageLabel.textAlignment = .center
            singleMessageLabel.numberOfLines = 0
            singleMessageLabel.textColor = viewModel.singleMessageLabelTextColor
            singleMessageLabel.font = viewModel.singleMessageLabelFont
            singleMessageLabel.text = viewModel.singleMessageLabelText

            tableView.backgroundColor = viewModel.detailsBackgroundBackgroundColor
            tableView.reloadData()
            tableViewContentSizeObserver = tableView.observe(\UITableView.contentSize, options: [.new]) { [weak self] (_, change) in
                guard let strongSelf = self else { return }
                guard let newSize = change.newValue else { return }
                strongSelf.tableViewHeightConstraint.constant = newSize.height
            }

            detailsBackground.backgroundColor = viewModel.detailsBackgroundBackgroundColor

            actionButton.setTitleColor(viewModel.actionButtonTitleColor, for: .normal)
            actionButton.setBackgroundColor(viewModel.actionButtonBackgroundColor, forState: .normal)
            actionButton.titleLabel?.font = viewModel.actionButtonTitleFont
            actionButton.setTitle(viewModel.actionButtonTitle, for: .normal)
            actionButton.layer.masksToBounds = true

            cancelButton.setTitleColor(viewModel.cancelButtonTitleColor, for: .normal)
            cancelButton.setBackgroundColor(viewModel.cancelButtonBackgroundColor, forState: .normal)
            cancelButton.titleLabel?.font = viewModel.cancelButtonTitleFont
            cancelButton.setTitle(viewModel.cancelButtonTitle, for: .normal)
            cancelButton.layer.masksToBounds = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        actionButton.layer.cornerRadius = actionButton.frame.size.height / 2
    }

    @objc func proceed() {
        delegate?.didPressProceed(in: self)
    }

    @objc func cancel() {
        if let delegate = delegate {
            delegate.didPressCancel(in: self)
        } else {
            dismiss(animated: true)
        }
    }
}

extension ConfirmSignMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConfirmSignMessageTableViewCell.identifier, for: indexPath) as! ConfirmSignMessageTableViewCell
        if let viewModel = viewModel {
            cell.configure(viewModel: viewModel.viewModelForTypedMessage(at: indexPath.row))
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let viewModel = viewModel {
            return viewModel.typedMessagesCount
        } else {
            return 0
        }
    }
}
