// Copyright SIX DAY LLC. All rights reserved.
import UIKit
import TrustKeystore
import QRCodeReaderViewController

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: Wallet, in viewController: ImportWalletViewController)
}

class ImportWalletViewController: UIViewController, CanScanQRCode {
    struct ValidationError: LocalizedError {
        var msg: String
        var errorDescription: String? {
            return msg
        }
    }

    private let keystore: Keystore
    private let viewModel = ImportWalletViewModel()
    //We don't actually use the rounded corner here, but it's a useful "content" view here
    private let roundedBackground = RoundedBackground()
    private let scrollView = UIScrollView()
    private let tabBar = ImportWalletTabBar()
    private let keystoreJSONTextView = TextView()
    private let passwordTextField = TextField()
    private let privateKeyTextView = TextView()
    private let watchAddressTextField = AddressTextField()
    private var keystoreJSONControlsStackView: UIStackView!
    private var privateKeyControlsStackView: UIStackView!
    private var watchControlsStackView: UIStackView!
    private let buttonsBar = ButtonsBar(numberOfButtons: 1)

    weak var delegate: ImportWalletViewControllerDelegate?

    init(keystore: Keystore) {
        self.keystore = keystore

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title

        roundedBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(roundedBackground)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        roundedBackground.addSubview(scrollView)

        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        keystoreJSONTextView.label.translatesAutoresizingMaskIntoConstraints = false
        keystoreJSONTextView.delegate = self
        keystoreJSONTextView.translatesAutoresizingMaskIntoConstraints = false
        keystoreJSONTextView.returnKeyType = .next

        passwordTextField.label.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.delegate = self
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.returnKeyType = .done
        passwordTextField.isSecureTextEntry = true

        privateKeyTextView.label.translatesAutoresizingMaskIntoConstraints = false
        privateKeyTextView.delegate = self
        privateKeyTextView.translatesAutoresizingMaskIntoConstraints = false
        privateKeyTextView.returnKeyType = .done

        watchAddressTextField.translatesAutoresizingMaskIntoConstraints = false
        watchAddressTextField.delegate = self
        watchAddressTextField.returnKeyType = .done

        keystoreJSONControlsStackView = [
            keystoreJSONTextView.label,
            .spacer(height: 4),
            keystoreJSONTextView,
            .spacer(height: 10),
            passwordTextField.label,
            .spacer(height: 4),
            passwordTextField,
        ].asStackView(axis: .vertical)
        keystoreJSONControlsStackView.translatesAutoresizingMaskIntoConstraints = false

        privateKeyControlsStackView = [
            privateKeyTextView.label,
            .spacer(height: 4),
            privateKeyTextView,
        ].asStackView(axis: .vertical)
        privateKeyControlsStackView.translatesAutoresizingMaskIntoConstraints = false

        watchControlsStackView = [
            watchAddressTextField.label,
            .spacer(height: 4),
            watchAddressTextField,
            watchAddressTextField.ensAddressLabel,
        ].asStackView(axis: .vertical)
        watchControlsStackView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = [
            tabBar,
            .spacer(height: 10),
            keystoreJSONControlsStackView,
            privateKeyControlsStackView,
            watchControlsStackView,
        ].asStackView(axis: .vertical, alignment: .center)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        let footerBar = UIView()
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        footerBar.backgroundColor = .clear
        roundedBackground.addSubview(footerBar)

        footerBar.addSubview(buttonsBar)

        let xMargin  = CGFloat(7)
        let heightThatFitsPrivateKeyNicely = CGFloat(100)
        NSLayoutConstraint.activate([
            keystoreJSONTextView.heightAnchor.constraint(equalToConstant: heightThatFitsPrivateKeyNicely),
            privateKeyTextView.heightAnchor.constraint(equalToConstant: heightThatFitsPrivateKeyNicely),

            tabBar.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),

            keystoreJSONControlsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: xMargin),
            keystoreJSONControlsStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -xMargin),
            privateKeyControlsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: xMargin),
            privateKeyControlsStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -xMargin),
            watchControlsStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: xMargin),
            watchControlsStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -xMargin),

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            buttonsBar.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor),
            buttonsBar.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor),
            buttonsBar.topAnchor.constraint(equalTo: footerBar.topAnchor),
            buttonsBar.heightAnchor.constraint(equalToConstant: ButtonsBar.buttonsHeight),

            footerBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerBar.topAnchor.constraint(equalTo: view.layoutGuide.bottomAnchor, constant: -ButtonsBar.buttonsHeight - ButtonsBar.marginAtBottomScreen),
            footerBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerBar.topAnchor),
        ] + roundedBackground.createConstraintsWithContainer(view: view))

        configure()
        showKeystoreControlsOnly()

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: R.image.import_options(), style: .done, target: self, action: #selector(importOptions)),
            UIBarButtonItem(image: R.image.qr_code_icon(), style: .done, target: self, action: #selector(openReader)),
        ]

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.demo()
            }
        }
    }

    func configure() {
        view.backgroundColor = viewModel.backgroundColor

        keystoreJSONTextView.configureOnce()
        keystoreJSONTextView.label.textAlignment = .center
        keystoreJSONTextView.label.text = viewModel.keystoreJSONLabel

        passwordTextField.configureOnce()
        passwordTextField.label.textAlignment = .center
        passwordTextField.label.text = viewModel.passwordLabel

        privateKeyTextView.configureOnce()
        privateKeyTextView.label.textAlignment = .center
        privateKeyTextView.label.text = viewModel.privateKeyLabel

        watchAddressTextField.label.text = viewModel.watchAddressLabel

        watchAddressTextField.configureOnce()

        buttonsBar.configure()
        let importButton = buttonsBar.buttons[0]
        importButton.setTitle(R.string.localizable.importWalletImportButtonTitle(), for: .normal)
        importButton.addTarget(self, action: #selector(importWallet), for: .touchUpInside)
    }

    func didImport(account: Wallet) {
        delegate?.didImportAccount(account: account, in: self)
    }

    ///Returns true only if valid
    private func validate() -> Bool {
        switch tabBar.tab {
        case .keystore:
            return validateKeystore()
        case .privateKey:
            return validatePrivateKey()
        case .watch:
            return validateWatch()
        }
    }

    ///Returns true only if valid
    private func validateKeystore() -> Bool {
        if keystoreJSONTextView.value.isEmpty {
            displayError(title: viewModel.keystoreJSONLabel, error: ValidationError(msg: R.string.localizable.warningFieldRequired()))
            return false
        }
        if passwordTextField.value.isEmpty {
            displayError(title: viewModel.passwordLabel, error: ValidationError(msg: R.string.localizable.warningFieldRequired()))
            return false
        }
        return true
    }

    ///Returns true only if valid
    private func validatePrivateKey() -> Bool {
        if let validationError = PrivateKeyRule().isValid(value: privateKeyTextView.value) {
            displayError(error: ValidationError(msg: validationError.msg))
            return false
        }
        return true
    }

    ///Returns true only if valid
    private func validateWatch() -> Bool {
        if let validationError = EthereumAddressRule().isValid(value: watchAddressTextField.value) {
            displayError(error: ValidationError(msg: validationError.msg))
            return false
        }
        return true
    }

    @objc func importWallet() {
        guard validate() else { return }

        let keystoreInput = keystoreJSONTextView.value.trimmed
        let privateKeyInput = privateKeyTextView.value.trimmed.drop0x
        let password = passwordTextField.value.trimmed
        let watchInput = watchAddressTextField.value.trimmed

        displayLoading(text: R.string.localizable.importWalletImportingIndicatorLabelTitle(), animated: false)

        let importType: ImportType = {
            switch tabBar.tab {
            case .keystore:
                return .keystore(string: keystoreInput, password: password)
            case .privateKey:
                return .privateKey(privateKey: privateKeyInput)
            case .watch:
                let address = Address(string: watchInput)! // Address validated by form view.
                return .watch(address: address)
            }
        }()

        keystore.importWallet(type: importType) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.hideLoading(animated: false)
            switch result {
            case .success(let account):
                strongSelf.didImport(account: account)
            case .failure(let error):
                strongSelf.displayError(error: error)
            }
        }
    }

    @objc func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoWallet = Wallet(type: .watch(Address(string: "0xD663bE6b87A992C5245F054D32C7f5e99f5aCc47")!))
        delegate?.didImportAccount(account: demoWallet, in: self)
    }

    @objc func importOptions(sender: UIBarButtonItem) {
        let alertController = UIAlertController(
            title: R.string.localizable.importWalletImportAlertSheetTitle(),
            message: .none,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.barButtonItem = sender
        alertController.addAction(UIAlertAction(
            title: R.string.localizable.importWalletImportAlertSheetOptionTitle(),
            style: .default
        ) {  [weak self] _ in
            self?.showDocumentPicker()
        })
        alertController.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in })
        present(alertController, animated: true)
    }

    func showDocumentPicker() {
        let types = ["public.text", "public.content", "public.item", "public.data"]
        let controller = UIDocumentPickerViewController(documentTypes: types, in: .import)
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true, completion: nil)
    }

    @objc func openReader() {
        guard AVCaptureDevice.authorizationStatus(for: .video) != .denied else {
            promptUserOpenSettingsToChangeCameraPermission()
            return
        }
        let controller = QRCodeReaderViewController(cancelButtonTitle: nil, chooseFromPhotoLibraryButtonTitle: R.string.localizable.photos())
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    func setValueForCurrentField(string: String) {
        switch tabBar.tab {
        case .keystore:
            keystoreJSONTextView.value = string
        case .privateKey:
            privateKeyTextView.value = string
        case .watch:
            watchAddressTextField.value = string
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func showKeystoreControlsOnly() {
        keystoreJSONControlsStackView.isHidden = false
        privateKeyControlsStackView.isHidden = true
        watchControlsStackView.isHidden = true
    }
    private func showPrivateKeyControlsOnly() {
        keystoreJSONControlsStackView.isHidden = true
        privateKeyControlsStackView.isHidden = false
        watchControlsStackView.isHidden = true
    }
    private func showWatchControlsOnly() {
        keystoreJSONControlsStackView.isHidden = true
        privateKeyControlsStackView.isHidden = true
        watchControlsStackView.isHidden = false
    }

    private func moveFocusToTextEntryField(after textInput: UIView) {
        switch textInput {
        case keystoreJSONTextView:
            _ = passwordTextField.becomeFirstResponder()
        case passwordTextField:
            view.endEditing(true)
        case privateKeyTextView:
            view.endEditing(true)
        case watchAddressTextField:
            view.endEditing(true)
        default:
            break
        }
    }
}

extension ImportWalletViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard controller.documentPickerMode == UIDocumentPickerMode.import else { return }
        let text = try? String(contentsOfFile: url.path)
        if let text = text {
            keystoreJSONTextView.value = text
        }
    }
}

extension ImportWalletViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        setValueForCurrentField(string: result)
        reader.dismiss(animated: true)
    }
}

extension ImportWalletViewController: TextFieldDelegate {
    func shouldReturn(in textField: TextField) -> Bool {
        moveFocusToTextEntryField(after: textField)
        return false
    }

    func doneButtonTapped(for textField: TextField) {
        view.endEditing(true)
    }

    func nextButtonTapped(for textField: TextField) {
        moveFocusToTextEntryField(after: textField)
    }
}

extension ImportWalletViewController: TextViewDelegate {
    func shouldReturn(in textView: TextView) -> Bool {
        moveFocusToTextEntryField(after: textView)
        return false
    }

    func doneButtonTapped(for textView: TextView) {
        view.endEditing(true)
    }

    func nextButtonTapped(for textView: TextView) {
        moveFocusToTextEntryField(after: textView)
    }
}

extension ImportWalletViewController: AddressTextFieldDelegate {
    func displayError(error: Error, for textField: AddressTextField) {
        displayError(error: error)
    }

    func openQRCodeReader(for textField: AddressTextField) {
        openReader()
    }

    func didPaste(in textField: AddressTextField) {
        view.endEditing(true)
    }

    func shouldReturn(in textField: AddressTextField) -> Bool {
        moveFocusToTextEntryField(after: textField)
        return false
    }

    func didChange(to string: String, in textField: AddressTextField) {
    }
}

extension ImportWalletViewController: ImportWalletTabBarDelegate {
    func didPressImportWalletTab(tab: ImportWalletTab, in tabBar: ImportWalletTabBar) {
        switch tab {
        case .keystore:
            showKeystoreControlsOnly()
        case .privateKey:
            showPrivateKeyControlsOnly()
        case .watch:
            showWatchControlsOnly()
        }
    }
}
