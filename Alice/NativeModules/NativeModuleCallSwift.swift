//
//  NativeModuleCallSwift.swift
//  AlphaWallet
//
//  Created by lmcmz on 29/5/19.
//

import Foundation


@objc(NativeModuleCallSwift)
class NativeModuleCallSwift : NSObject {
    
    // This is the method exposed to React Native. It can't handle
    // the first parameter being named. http://stackoverflow.com/a/39840952/155186
    @objc func helloSwift(_ from: String, to:String, value: String) {
        
//        UnconfirmedTransaction
        
//        SendCoordinator.
        // You won't be on the main thread when called from JavaScript
        DispatchQueue.main.async {
//            HUDManager.shared.showAlertView(view: TransactionAlertView.instanceFromNib())
            TransactionManager.showPaymentView()
        }
    }
}
