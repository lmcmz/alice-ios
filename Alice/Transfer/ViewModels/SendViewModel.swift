// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

struct SendViewModel {
    private let transferType: TransferType
    private let session: WalletSession
    private let storage: TokensDataStore

    init(transferType: TransferType, session: WalletSession, storage: TokensDataStore) {
        self.transferType = transferType
        self.session = session
        self.storage = storage
    }

    var destinationAddress: Address {
        return transferType.contract()
    }

    var backgroundColor: UIColor {
        return Colors.appBackground
    }

    var token: TokenObject? {
        switch transferType {
        case .nativeCryptocurrency:
            return nil
        case .ERC20Token(let token, _, _):
            return token
        case .ERC875Token(let token):
            return token
        case .ERC875TokenOrder(let token):
            return token
        case .ERC721Token(let token):
            return token
        case .dapp:
            return nil
        }
    }

    var showAlternativeAmount: Bool {
        guard let currentTokenInfo = storage.tickers?[destinationAddress.description], let price = Double(currentTokenInfo.price_usd), price > 0 else {
            return false
        }
        return true
    }

    var textFieldsLabelTextColor: UIColor {
        return Colors.appGrayLabelColor
    }
    var textFieldsLabelFont: UIFont {
        return Fonts.regular(size: 10)!
    }
}
