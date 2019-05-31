// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum URLServiceProvider {
    case telegram
    case twitter
    case reddit
    case facebook

    var title: String {
        switch self {
        case .telegram: return "Telegram"
        case .twitter: return "Twitter"
        case .reddit: return "Reddit"
        case .facebook: return "Facebook"
        }
    }

    //TODO should probably change or remove `localURL` since iOS supports deep links now
    var localURL: URL? {
        switch self {
        case .telegram:
            return URL(string: "https://t.me/AlphaWalletGroup")!
        case .twitter:
            return URL(string: "twitter://user?screen_name=\(Constants.twitterUsername)")!
        case .reddit:
            return URL(string: "reddit.com\(Constants.redditGroupName)")
        case .facebook:
            return URL(string: "fb://profile?id=\(Constants.facebookUsername)")
        }
    }

    var remoteURL: URL {
        return URL(string: remoteURLString)!
    }

    private var remoteURLString: String {
        switch self {
        case .telegram:
            return "https://t.me/AlphaWalletGroup"
        case .twitter:
            return "https://twitter.com/\(Constants.twitterUsername)"
        case .reddit:
            return "https://reddit.com/\(Constants.redditGroupName)"
        case .facebook:
            return "https://www.facebook.com/\(Constants.facebookUsername)"
        }
    }

    var image: UIImage? {
        switch self {
        case .telegram: return R.image.settings_telegram()
        case .twitter: return R.image.settings_twitter()
        case .reddit: return R.image.settings_reddit()
        case .facebook: return R.image.settings_facebook()
        }
    }
}
