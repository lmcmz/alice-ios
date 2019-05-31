//
//  TransactionManager.swift
//  AlphaWallet
//
//  Created by lmcmz on 30/5/19.
//

import Foundation
import APIKit
import JSONRPCKit
import Result

class TransactionManager: NSObject {
    
    static let shared = TransactionManager()
    let session: WalletSession
    let wallet: Wallet
    private let confirmType: ConfirmType
    private let keystore: Keystore
    
    override init() {
        keystore = AppDelegate.keystore()
        wallet = keystore.recentlyUsedWallet!
        let walletSession = InCoordinator.walletSession()
        session = walletSession[.main]
        self.confirmType = .signThenSend
    }
    
    func send(transaction: UnsignedTransaction, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        if transaction.nonce >= 0 {
            signAndSend(transaction: transaction, completion: completion)
        } else {
            let request = EtherServiceRequest(server: session.server, batch: BatchFactory().create(GetTransactionCountRequest(
                address: session.account.address.description,
                state: "pending"
            )))
            //TODO Verify we need a strong reference to self
            Session.send(request) { result in
                //guard let `self` = self else { return }
                switch result {
                case .success(let count):
                    let transaction = self.appendNonce(to: transaction, currentNonce: count)
                    self.signAndSend(transaction: transaction, completion: completion)
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    private func appendNonce(to: UnsignedTransaction, currentNonce: Int) -> UnsignedTransaction {
        return UnsignedTransaction(
            value: to.value,
            account: to.account,
            to: to.to,
            nonce: currentNonce,
            data: to.data,
            gasPrice: to.gasPrice,
            gasLimit: to.gasLimit,
            server: to.server
        )
    }

    func signAndSend(
        transaction: UnsignedTransaction,
        completion: @escaping (Result<ConfirmResult, AnyError>) -> Void
        ) {
        let signedTransaction = keystore.signTransaction(transaction)
        switch signedTransaction {
        case .success(let data):
            switch confirmType {
            case .sign:
                completion(.success(.signedTransaction(data)))
            case .signThenSend:
                let request = EtherServiceRequest(server: session.server, batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: data.hexEncoded)))
                Session.send(request) { result in
                    switch result {
                    case .success(let transactionID):
                        completion(.success(.sentTransaction(SentTransaction(id: transactionID, original: transaction))))
                    case .failure(let error):
                        completion(.failure(AnyError(error)))
                    }
                }
            }
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
}
