// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import BigInt
import TrustKeystore

class TokenObject: Object {
    static func generatePrimaryKey(fromContract contract: String, server: RPCServer) -> String {
        return "\(contract)-\(server.chainID)"
    }

    @objc dynamic var primaryKey: String = ""
    @objc dynamic var chainId: Int = 0
    @objc dynamic var contract: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var decimals: Int = 0
    @objc dynamic var value: String = ""
    @objc dynamic var isDisabled: Bool = false
    @objc dynamic var rawType: String = TokenType.erc20.rawValue

    let balance = List<TokenBalance>()

    var nonZeroBalance: [TokenBalance] {
        return Array(balance.filter { isNonZeroBalance($0.balance) })
    }

    var type: TokenType {
        get {
            return TokenType(rawValue: rawType)!
        }
        set {
            rawType = newValue.rawValue
        }
    }

    convenience init(
            contract: String = "",
            server: RPCServer,
            name: String = "",
            symbol: String = "",
            decimals: Int = 0,
            value: String,
            isCustom: Bool = false,
            isDisabled: Bool = false,
            type: TokenType
    ) {
        self.init()
        self.primaryKey = TokenObject.generatePrimaryKey(fromContract: contract, server: server)
        self.contract = contract
        self.chainId = server.chainID
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.value = value
        self.isDisabled = isDisabled
        self.type = type
    }

    var address: Address {
        return Address(uncheckedAgainstNullAddress: contract)!
    }

    var valueBigInt: BigInt {
        return BigInt(value) ?? BigInt()
    }

    override static func primaryKey() -> String? {
        return "primaryKey"
    }

    override static func ignoredProperties() -> [String] {
        return ["type"]
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TokenObject else { return false }
        return object.contract.sameContract(as: contract)
    }

    var title: String {
        let localizedNameFromAssetDefinition = XMLHandler(contract: contract).getName()
        let compositeName = compositeTokenName(fromContractName: name, localizedNameFromAssetDefinition: localizedNameFromAssetDefinition)

        if compositeName.isEmpty {
            return symbol
        } else {
            return "\(compositeName) (\(symbol))"
        }
    }

    var isERC721: Bool {
        switch type {
        case .erc721:
            return true
        case .nativeCryptocurrency, .erc20, .erc875:
            return false
        }
    }

    var server: RPCServer {
        return .init(chainID: chainId)
    }
}

func isNonZeroBalance(_ balance: String) -> Bool {
    return !isZeroBalance(balance)
}

func isZeroBalance(_ balance: String) -> Bool {
    if balance == Constants.nullTokenId {
        return true
    }
    return false
}

func compositeTokenName(fromContractName contractName: String, localizedNameFromAssetDefinition: String) -> String {
    let compositeName: String
    //TODO improve and remove the check for "N/A". Maybe a constant
    if localizedNameFromAssetDefinition.isEmpty || localizedNameFromAssetDefinition == "N/A" {
        compositeName = contractName
    } else {
        if contractName.isEmpty {
            compositeName = localizedNameFromAssetDefinition
        } else {
            compositeName = "\(contractName) \(localizedNameFromAssetDefinition)"
        }
    }
    return compositeName
}
