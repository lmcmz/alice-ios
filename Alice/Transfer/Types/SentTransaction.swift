// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct SentTransaction {
    let id: String
    let original: UnsignedTransaction
}

extension SentTransaction {
    static func from(from: Address, transaction: SentTransaction) -> Transaction {
        return Transaction(
            id: transaction.id,
            server: transaction.original.server,
            blockNumber: 0,
            from: from.description,
            to: transaction.original.to?.description ?? "",
            value: transaction.original.value.description,
            gas: transaction.original.gasLimit.description,
            gasPrice: transaction.original.gasPrice.description,
            gasUsed: "",
            nonce: String(transaction.original.nonce),
            date: Date(),
            //TODO we should know what type of transaction (transfer) here and create accordingly if it's ERC20, ERC721, ERC875
            localizedOperations: [],
            state: .pending,
            isErc20Interaction: false
        )
    }
}
