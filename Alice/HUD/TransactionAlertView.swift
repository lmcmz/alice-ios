//
//  TransactionAlertView.swift
//  AlphaWallet
//
//  Created by lmcmz on 29/5/19.
//

import UIKit
import TrustKeystore
import BigInt

public extension NSObject{
    class var nameOfClass: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var nameOfClass: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}

class TransactionAlertView: UIView {
    
    
    class func instanceFromNib() -> UIView {
        let view = UINib(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
        return view
    }
    
    
    @IBAction func sendButtonClicked() {
        let address = Address(string: "0xa1b02d8c67b0fdcf4e379855868deb470e169cfb")
        let amountString = "0.003"
        let parsedValue: BigInt? = EtherNumberFormatter.full.number(from: amountString, units: .ether)
        
        
        let session = TransactionManager.shared.session
        let server = TransactionManager.shared.session.server
        
        let transaction = UnconfirmedTransaction(
            transferType: .nativeCryptocurrency(server: server, destination: address, amount: parsedValue),
            value: parsedValue!,
            to: address,
            data: Data(),
            gasLimit: .none,
            tokenId: .none,
            gasPrice: BigInt("1"),
            nonce: .none,
            v: .none,
            r: .none,
            s: .none,
            expiry: .none,
            indices: .none,
            tokenIds: .none
        )
        
        guard case .real(let account) = session.account.type else { return }
        
        let configurator = TransactionConfigurator(
            session: TransactionManager.shared.session,
            account: account,
            transaction: transaction
        )
        
        
        let tx = configurator.formUnsignedTransaction()
        TransactionManager.shared.send(transaction: tx) { [weak self] (result) in
//            guard let strongSelf = self else { return }
            switch result {
            case .success(let data):
                print("SUCCESS")
            case .failure(let error):
                print("FAIL")
            }
            
        }
    }

}
