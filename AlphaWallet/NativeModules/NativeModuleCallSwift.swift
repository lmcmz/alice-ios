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
            HUDManager.shared.showAlertView(view: TransactionAlertView.instanceFromNib())
            var server = RPCServer(chainID: Config.getChainId())
            let token = TokensDataStore.token(forServer: server)
            let requester = DAppRequester(title: "Test", url: URL(string: "www.google.com"))
            let transfer = Transfer(server: server, type: .dapp(token, requester))

//            let dict = []
//            let command = DappCommand(name: .signTransaction, id: 8888, object: ["gasPrice": )])
//            DappCommandObjectValue
//            DappCommand(name: .signTransaction, id: 8888, object: ["gasPrice"  : DappCommandObjectValue(from: "1233"),
//                                                                   "chainType" : DappCommandObjectValue(from: "1233"),
//                                                                   "to"        : DappCommandObjectValue(from: "1233"),
//                                                                    ])
//            
//            executeTransaction
//                DappAction.fromMessage(message)
            
            
//            let action = DappAction.fromCommand(command, transfer: transfer)
        }
    }
}
