// Copyright © 2018 Stormbird PTE. LTD.

import Foundation
import BigInt
import PromiseKit
import Result
import TrustKeystore

///This class uses 2 caches:
///
///1. Store the promises used to make function calls. This is so we don't make the same function calls (over network) + arguments combination multiple times concurrently. Once the call completes, we remove it from the cache.
///2. Store function call result as a subscribable. This makes it easier to display the data fetched from the database as well as function call and when when a refresh (another function call) updates the value.
class CallForAssetAttributeCoordinator {
    private static var functionCallCache = [AssetAttributeFunctionCall: Subscribable<AssetAttributeValue>]()

    private let server: RPCServer
    private let tokensDataStore: TokensDataStore
    private var promiseCache = [AssetAttributeFunctionCall: Promise<AssetAttributeValue>]()

    var contractToRefetch: String?

    init(server: RPCServer, tokensDataStore: TokensDataStore) {
        self.server = server
        self.tokensDataStore = tokensDataStore

        NotificationCenter.default.addObserver(self, selector: #selector(refreshFunctionCallBasedAssetAttributesForAllTokens), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    func getValue(
            forAttributeName attributeName: String,
            tokenId: BigUInt,
            functionCall: AssetAttributeFunctionCall
    ) -> Subscribable<AssetAttributeValue> {
        let refreshContract = shouldRefresh(functionCall: functionCall)
        let subscribable: Subscribable<AssetAttributeValue>
        if let cachedResult = cache(forFunctionCall: functionCall) {
            if refreshContract {
                subscribable = cachedResult
            } else {
                return cachedResult
            }
        } else {
            subscribable = Subscribable<AssetAttributeValue>(nil)
        }

        cache(functionCall: functionCall, result: subscribable)

        if !refreshContract {
            if let value = jsonAttributeValueInDatabase(forContract: functionCall.contract, tokenId: tokenId, attributeName: attributeName) {
                //Needed because types like NSTaggedPointerString and __NSCFBoolean (which are parsed from JSON) aren't convertible directly to AssetAttributeValue if we don't cast to String and Bool first
                if let value = value as? Bool {
                    subscribable.value = value
                    return subscribable
                } else if let value = value as? String {
                    subscribable.value = value
                    return subscribable
                }
            }
        }

        if promiseCache[functionCall] != nil {
            return subscribable
        }

        let promise = makeRpcPromise(forAttributeName: attributeName, tokenId: tokenId, functionCall: functionCall)
        promiseCache[functionCall] = promise

        //TODO need to throttle smart contract function calls?
        promise.done { [weak self] result in
            guard let strongSelf = self else { return }
            subscribable.value = result as AssetAttributeValue
            strongSelf.promiseCache.removeValue(forKey: functionCall)
        }.catch { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.promiseCache.removeValue(forKey: functionCall)
        }

        return subscribable
    }

    @objc func refreshFunctionCallBasedAssetAttributesForAllTokens() {
        for each in tokensDataStore.objects {
            refreshFunctionCallBasedAssetAttributes(forToken: each)
        }
    }

    private func refreshFunctionCallBasedAssetAttributes(forToken token: TokenObject) {
        contractToRefetch = token.contract
        _ = TokenAdaptor(token: token).getTokenHolders()
        contractToRefetch = nil
    }

    private func updateDataStore(forContract contract: String, tokenId: BigUInt, attributeName: String, value: AssetAttributeValue) {
        tokensDataStore.update(contract: contract, tokenId: String(tokenId, radix: 16).add0x, action: .updateJsonProperty(attributeName, value))
    }

    private func jsonAttributeValueInDatabase(forContract contract: String, tokenId: BigUInt, attributeName: String) -> Any? {
        return tokensDataStore.jsonAttributeValue(forContract: contract, tokenId: String(tokenId, radix: 16).add0x, attributeName: attributeName)
    }

    private func cache(functionCall: AssetAttributeFunctionCall, result: Subscribable<AssetAttributeValue>) {
        CallForAssetAttributeCoordinator.functionCallCache[functionCall] = result
    }

    private func cache(forFunctionCall functionCall: AssetAttributeFunctionCall) -> Subscribable<AssetAttributeValue>? {
        return CallForAssetAttributeCoordinator.functionCallCache[functionCall]
    }

    private func shouldRefresh(functionCall: AssetAttributeFunctionCall) -> Bool {
        if let contractToRefetch = contractToRefetch, contractToRefetch.sameContract(as: functionCall.contract) {
            return true
        } else {
            return false
        }
    }

    private func makeRpcPromise(
            forAttributeName attributeName: String,
            tokenId: BigUInt,
            functionCall: AssetAttributeFunctionCall) -> Promise<AssetAttributeValue> {
        return Promise<AssetAttributeValue> { seal in
            guard let contract = Address(string: functionCall.contract) else {
                seal.reject(Web3Error(description: "Error converting contract address: \(functionCall.contract)"))
                return
            }

            guard let function = CallForAssetAttribute(functionName: functionCall.functionName, inputs: functionCall.inputs, output: functionCall.output) else {
                seal.reject(AnyError(Web3Error(description: "Failed to create CallForAssetAttribute instance for function: \(functionCall.functionName)")))
                return
            }

            //Fine to store a strong reference to self here because it's still useful to cache the function call result
            callSmartContract(withServer: server, contract: contract, functionName: functionCall.functionName, abiString: "[\(function.abi)]", parameters: functionCall.arguments).done { dictionary in
                if let value = dictionary["0"] {
                    switch functionCall.output.type {
                    case .bool:
                        let result = value as? Bool ?? false
                        seal.fulfill(result)
                        self.updateDataStore(forContract: functionCall.contract, tokenId: tokenId, attributeName: attributeName, value: result)
                    case .string:
                        let result = value as? String ?? ""
                        seal.fulfill(result)
                        self.updateDataStore(forContract: functionCall.contract, tokenId: tokenId, attributeName: attributeName, value: result)
                    case .int, .int8, .int16, .int32, .int64, .int128, .int256, .uint, .uint8, .uint16, .uint32, .uint64, .uint128, .uint256:
                        let result = value as? Int ?? 0
                        seal.fulfill(result)
                        self.updateDataStore(forContract: functionCall.contract, tokenId: tokenId, attributeName: attributeName, value: result)
                    }
                } else {
                    seal.reject(Web3Error(description: "nil result from calling: \(function.name)() on contract: \(functionCall.contract)"))
                }
            }.catch {
                seal.reject(AnyError($0))
            }
        }
    }
}
