//
// Created by James Sangalli on 15/2/18.
// Copyright © 2018 Stormbird PTE. LTD.
// Sends the sales orders to and from the market queue server
//

import Foundation
import Alamofire
import SwiftyJSON
import BigInt

//"orders": [
//    {
//    "message": "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACOG8m/BAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAWojJJwB77oK92ehmsr0RR4CkfyJhxoTjAAIAAwAE)",
//    "expiry": "1518913831",
//    "start": "32800312",
//    "count": "3",
//    "price": "10000000000000000",
//    "signature": "jrzcgpsnV7IPGE3nZQeHQk5vyZdy5c8rHk0R/iG7wpiK9NT730I//DN5Dg5fHs+s4ZFgOGQnk7cXLQROBs9NvgE="
//    }
//]

public class MarketQueueHandler {

    private let baseURL = "https://482kdh4npg.execute-api.ap-southeast-1.amazonaws.com/dev/"
    private let contractAddress = "bC9a1026A4BC6F0BA8Bbe486d1D09dA5732B39e4".lowercased()

    public func getOrders(callback: @escaping (_ result: Any) -> Void) {
        Alamofire.request(baseURL + "contract/" + contractAddress, method: .get).responseJSON { [weak self] response in
            guard let strongSelf = self else { return }
            var orders = [SignedOrder]()
            if response.result.value != nil {
                let parsedJSON = try! JSON(data: response.data!)
                for i in 0...parsedJSON.count - 1 {
                    let orderObj: JSON = parsedJSON["orders"][i]
                    if orderObj == .null {
                        //String not used in UI
                        callback("no orders")
                        return
                    }
                    orders.append(strongSelf.parseOrder(orderObj))
                }
                callback(orders)
            }
        }
    }

    func parseOrder(_ orderObj: JSON) -> SignedOrder {
        let orderString = orderObj["message"].string!
        let message = Data(base64Encoded: orderString)!.hex()
        let price = message.substring(to: 64)
        let expiry = message.substring(with: Range(uncheckedBounds: (64, 128)))
        let contractAddress = "0x" + message.substring(with: Range(uncheckedBounds: (128, 168)))
        let indices = message.substring(from: 168)
        let order = Order(
                price: BigUInt(price, radix: 16)!,
                indices: indices.hexa2Bytes.map({ UInt16($0) }),
                expiry: BigUInt(expiry, radix: 16)!,
                contractAddress: contractAddress,
                count: BigUInt(orderObj["count"].intValue),
                nonce: BigUInt(0),
                tokenIds: [BigUInt](),
                spawnable: false,
                nativeCurrencyDrop: false
        )
        let signedOrder = SignedOrder(
                order: order,
                message: message.hexa2Bytes,
                signature: "0x" + Data(base64Encoded: orderObj["signature"].string!)!.hex()
        )
        return signedOrder
    }

    //only have to give first order to server then pad the signatures
    public func putOrderToServer(signedOrders: [SignedOrder],
                                 publicKey: String,
                                 callback: @escaping (_ result: Any) -> Void) {
        //TODO get encoding for count and start
        let query: String = baseURL + "public-key/" + publicKey + "?start=0" +
                ";count=" + signedOrders.count.description
        var messageBytes = signedOrders[0].message
        print(signedOrders[0].signature.count)

        for i in 0...signedOrders.count - 1 {
            for j in 0...64 {
                messageBytes.append(signedOrders[i].signature.hexa2Bytes[j])
            }
        }
        let headers: HTTPHeaders = ["Content-Type": "application/vnd.awallet-signed-orders-v0"]

        print(query)

        Alamofire.upload(Data(bytes: messageBytes), to: query, method: .put, headers: headers).response { response in
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                callback(data)
            }
        }
    }

}
