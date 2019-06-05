platform :ios, '10.0'
inhibit_all_warnings!
source 'https://github.com/CocoaPods/Specs.git'

target 'Alice' do
  use_frameworks!
  pod 'BigInt', '~> 3.0'
  pod 'R.swift', '~> 4.0.0' 
  pod 'JSONRPCKit', '~> 2.0.0'
  pod 'APIKit'
  pod 'Eureka', '~> 4.3'
  pod 'MBProgressHUD'
  pod 'StatefulViewController'
  pod 'QRCodeReaderViewController', :git=>'https://github.com/alicedapp/QRCodeReaderViewController.git', :branch=>'alphawallet'
  pod 'KeychainSwift'
  pod 'SwiftLint'
  pod 'SeedStackViewController'
  pod 'RealmSwift', '~> 3.9'
  pod 'Moya', '~> 10.0.1'
  pod 'JavaScriptKit'
  pod 'CryptoSwift'
  pod 'SwiftyXMLParser', :git => 'https://github.com/yahoojapan/SwiftyXMLParser.git'
  pod 'Kingfisher', '~> 4.0'
  pod 'AlphaWalletWeb3Provider', :git=>'https://github.com/alicedapp/AlphaWallet-web3-provider', :commit => 'f25206c50009d1eb922c3cc8c0ba91594155e8b6'
  pod 'TrezorCrypto', :git=>'https://github.com/alicedapp/trezor-crypto-ios.git', :commit => '50c16ba5527e269bbc838e80aee5bac0fe304cc7'
  pod 'TrustKeystore', :git => 'https://github.com/alicedapp/latest-keystore-snapshot.git', :commit => '9abdc1a63f1baf17facb26a3e049b5e335a95816'
  pod 'SwiftyJSON'
  pod 'web3swift', :git => 'https://github.com/alicedapp/web3swift.git', :commit => '2b3c5ee878212ce70768568def7e727f0f1ebf86'
  pod 'SAMKeychain'
  pod 'PromiseKit/CorePromise'
  pod 'PromiseKit/Alamofire'
  pod 'Macaw', :git => 'https://github.com/alicedapp/Macaw.git', :commit => 'c13e70e63dd1a2554b59e0aa75c12b93e2ee9dd8'
  pod 'Kanna', '~> 4.0.0'
  pod 'AWSSNS'
  # pod 'AWSCognito'
  
  pod 'SPStorkController'
  pod 'SwiftEntryKit', '1.0.1'
  pod 'SPStorkController'
  
  # React Native Dependencies
  pod 'React', :path => '../node_modules/react-native', :subspecs => [
  'Core',
  'CxxBridge',
  'DevSupport',
  'RCTText',
  'RCTAnimation',
  'RCTImage',
  'RCTActionSheet',
  'RCTNetwork',
  'RCTWebSocket',
  'RCTLinkingIOS'
  ]
  
  pod 'Folly', :podspec => '../node_modules/react-native/third-party-podspecs/Folly.podspec'
  pod 'yoga', :path => '../node_modules/react-native/ReactCommon/yoga'
  pod 'RNGestureHandler', :path => '../node_modules/react-native-gesture-handler'

  pod 'RNGestureHandler', :path => '../node_modules/react-native-gesture-handler'

  target 'AliceTests' do
      inherit! :search_paths
      # Pods for testing
      pod 'iOSSnapshotTestCase'
  end

  target 'AliceUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# Fix RN dependency issuse
def change_lines_in_file(file_path, &change)
  print "Fixing #{file_path}...\n"
  
  contents = []
  
  file = File.open(file_path, 'r')
  file.each_line do | line |
    contents << line
  end
  file.close
  
  File.open(file_path, 'w') do |f|
    f.puts(change.call(contents))
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if ['TrustKeystore'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
    if [
        'APIKit',
        'Kingfisher',
        'Macaw',
        'R.swift.Library',
        'RealmSwift',
        'Result',
        'SeedStackViewController',
        'SwiftyXMLParser',
        'JSONRPCKit',
        'BigInt',
        'Moya',
        'TrustKeystore'
    ].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4'
      end
    end
    
    if ['libsodium'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['USE_HEADERMAP'] = 'NO'
      end
    end
  end
  
  # https://github.com/facebook/yoga/issues/711#issuecomment-381098373
  change_lines_in_file('./Pods/Target Support Files/yoga/yoga-umbrella.h') do |lines|
    lines.reject do | line |
      [
      '#import "Utils.h"',
      '#import "YGLayout.h"',
      '#import "YGNode.h"',
      '#import "YGNodePrint.h"',
      '#import "YGStyle.h"',
      '#import "Yoga-internal.h"',
      ].include?(line.strip)
    end
  end
  
  # https://github.com/facebook/yoga/issues/711#issuecomment-374605785
  change_lines_in_file('../node_modules/react-native/React/Base/Surface/SurfaceHostingView/RCTSurfaceSizeMeasureMode.h') do |lines|
    unless lines[27].include?("#ifdef __cplusplus")
      lines.insert(27, "#ifdef __cplusplus")
      lines.insert(34, "#endif")
    end
    lines
  end
  
  # https://github.com/facebook/react-native/issues/13198
  change_lines_in_file('../node_modules/react-native/Libraries/NativeAnimation/RCTNativeAnimatedNodesManager.h') do |lines|
    lines.map { |line| line.include?("#import <RCTAnimation/RCTValueAnimatedNode.h>") ? '#import "RCTValueAnimatedNode.h"' : line }
  end
  
  # https://github.com/facebook/react-native/issues/16039
  change_lines_in_file('../node_modules/react-native/Libraries/WebSocket/RCTReconnectingWebSocket.m') do |lines|
    lines.map { |line| line.include?("#import <fishhook/fishhook.h>") ? '#import "fishhook.h"' : line }
  end
end
