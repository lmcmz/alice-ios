//
//  SwiftReactNativeBridge.m
//  AlphaWallet
//
//  Created by lmcmz on 29/5/19.
//

#import <Foundation/Foundation.h>


#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(NativeModuleCallSwift, NSObject)

// Type 1: Calling a Swift function from JavaScript
RCT_EXTERN_METHOD(helloSwift:(NSString *)from to:(NSString *)to value:(NSString *)value)

@end



//// Type 2: Calling a Swift function with a callback
//@interface RCT_EXTERN_MODULE(NativeModuleJavaScriptCallback, NSObject)
//
//RCT_EXTERN_METHOD(toggleSwiftButtonEnabled:(RCTResponseSenderBlock *)callback)
//
//@end
//
//
//
//// Type 3: Broadcasting data from Swift and listening in JavaScript
//@interface RCT_EXTERN_MODULE(NativeModuleBroadcastToJavaScript, RCTEventEmitter)
//@end
