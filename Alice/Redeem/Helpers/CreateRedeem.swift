//
// Created by James Sangalli on 2/3/18.
// Copyright © 2018 Stormbird PTE. LTD.
//

import Foundation
import BigInt
import TrustKeystore

class CreateRedeem {
    private let token: TokenObject

    init(token: TokenObject) {
        self.token = token
    }

    func generateTimeStamp() -> String {
        let time = NSDate().timeIntervalSince1970
        //rotate qr every 30 seconds for security (preventing screenshot claims)
        let minsTime = Int(time / 30) 
        return String(minsTime)
    }

    func redeemMessage(tokenIndices: [UInt16]) -> (message: String, qrCode: String) {
        let contractAddress = token.contract.add0x.lowercased()
        let messageForSigning = formIndicesSelection(indices: tokenIndices)
                + "," + generateTimeStamp() + "," + contractAddress
        let qrCodeData = formIndicesSelection(indices: tokenIndices)
        return (messageForSigning, qrCodeData)
    }

    /**
     * Generate a compact string representation of the indices of an
     * ERC875 asset.  Notice that this function is not used in this
     * class. It is used to return the selectionStr to be used as a
     * parameter of the constructor
    */
    func formIndicesSelection(indices: [UInt16]) -> String {
        let firstValue = indices[0] //lowest number
        let NIBBLE = 4
        let zeroCount = Int(firstValue) / NIBBLE
        let correctionFactor = zeroCount * NIBBLE
        /* the method here is easier to express with matrix programming like this:
        indexList = indexList - correctionFactor # reduce every element of the list by an int
        selection = sum(2^indexList)             # raise every element and add the result back */
        var bitFieldLookup = BigUInt("0")!
        for _ in 0...indices.count - 1 {
            let adder = BigUInt("2")?.power(Int(indices[0]) - correctionFactor)
            bitFieldLookup = bitFieldLookup.advanced(by: BigInt(adder!))
        }

        let bitIntLength: Int = bitFieldLookup.description.count
        var bitString = ""
        if bitIntLength < 10 {
            bitString = "0"
        }
        bitString += String(bitIntLength)
        if zeroCount < 100 {
            bitString += "0"
        }
        if zeroCount < 10 {
            bitString += "0"
        }

        bitString += String(zeroCount)
        bitString += String(bitFieldLookup)

        return bitString
    }

}
