// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import UIKit

struct TransferTokensCardQuantitySelectionViewModel {
    let token: TokenObject
    let tokenHolder: TokenHolder

    var headerTitle: String {
        let tokenTypeName = XMLHandler(contract: token.address.eip55String).getTokenTypeName(.plural, titlecase: .titlecase)
		return R.string.localizable.aWalletTokenTransferSelectQuantityTitle(tokenTypeName)
    }

    var maxValue: Int {
        return tokenHolder.tokens.count
    }

    var backgroundColor: UIColor {
        return Colors.appBackground
    }

    var subtitleColor: UIColor {
        return Colors.appGrayLabelColor
    }

    var subtitleFont: UIFont {
        return Fonts.regular(size: 10)!
    }

    var stepperBorderColor: UIColor {
        return Colors.appBackground
    }

    var subtitleText: String {
        let tokenTypeName = XMLHandler(contract: token.address.eip55String).getTokenTypeName()
		return R.string.localizable.aWalletTokenTransferQuantityTitle(tokenTypeName.localizedUppercase)
    }
}
