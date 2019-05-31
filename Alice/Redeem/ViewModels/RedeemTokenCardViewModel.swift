//
//  RedeemTokenCardViewModel.swift
//  Alpha-Wallet
//
//  Created by Oguzhan Gungor on 3/4/18.
//  Copyright © 2018 Alpha-Wallet. All rights reserved.
//

import Foundation
import UIKit

struct RedeemTokenCardViewModel {
    let token: TokenObject
    let tokenHolders: [TokenHolder]

    init(token: TokenObject) {
        self.token = token
        self.tokenHolders = TokenAdaptor(token: token).getTokenHolders()

        selectSoleTokenHolder()
    }

    private func selectSoleTokenHolder() {
        if tokenHolders.count == 1 {
            tokenHolders[0].isSelected = true
            tokenHolders[0].areDetailsVisible = true
        }
    }

    func item(for indexPath: IndexPath) -> TokenHolder {
        return tokenHolders[indexPath.row]
    }

    func numberOfItems(for section: Int) -> Int {
        return tokenHolders.count
    }

    var title: String {
        let tokenTypeName = XMLHandler(contract: token.address.eip55String).getTokenTypeName()
        return R.string.localizable.aWalletTokenRedeemSelectTokensTitle(tokenTypeName)
    }

    func toggleSelection(for indexPath: IndexPath) -> [IndexPath] {
        let tokenHolder = item(for: indexPath)
        var changed = [indexPath]
        if tokenHolder.areDetailsVisible {
            tokenHolder.areDetailsVisible = false
            tokenHolder.isSelected = false
        } else {
            for (i, each) in tokenHolders.enumerated() where each.areDetailsVisible {
                each.areDetailsVisible = false
                each.isSelected = false
                changed.append(.init(row: i, section: indexPath.section))
            }
            tokenHolder.areDetailsVisible = true
            tokenHolder.isSelected = true
        }
        return changed
    }
}
