// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

extension UIAlertController {

    static func askPassword(
            title: String = "",
            message: String = "",
            completion: @escaping (Result<String, ConfirmationError>) -> Void
    ) -> UIAlertController {
        let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: R.string.localizable.oK(), style: .default, handler: { _ -> Void in
            let textField = alertController.textFields![0] as UITextField
            let password = textField.text ?? ""
            completion(.success(password))
        }))
        alertController.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: { _ in
            completion(.failure(ConfirmationError.cancel))
        }))
        alertController.addTextField(configurationHandler: { (textField: UITextField!) -> Void in
            textField.placeholder = R.string.localizable.password()
            textField.isSecureTextEntry = true
        })
        return alertController
    }

    static func alert(title: String?,
                      message: String?,
                      alertButtonTitles: [String],
                      alertButtonStyles: [UIAlertAction.Style],
                      viewController: UIViewController,
                      preferredStyle: UIAlertController.Style = .alert,
                      completion: ((Int) -> Void)?) {

        let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: preferredStyle)

        alertButtonTitles.forEach { title in
            let alertStyle = alertButtonStyles[alertButtonTitles.index(of: title)!]
            let action = UIAlertAction(title: title, style: alertStyle, handler: { action in
                if completion != nil {
                    completion!(alertButtonTitles.index(of: action.title!)!)
                }
            })
            alertController.addAction(action)
        }
        viewController.present(alertController, animated: true, completion: nil)
    }

    static func alertController(
        title: String? = .none,
        message: String? = .none,
        style: UIAlertController.Style,
        in navigationController: NavigationController
    ) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertController.popoverPresentationController?.sourceView = navigationController.view
        alertController.popoverPresentationController?.sourceRect = navigationController.view.centerRect
        return alertController
    }
}
