//
//  HUDManager.swift
//  AlphaWallet
//
//  Created by lmcmz on 29/5/19.
//

import Foundation
import SwiftEntryKit
import QuickLayout


extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
    
    var maxEdge: CGFloat {
        return max(width, height)
    }
}


class HUDManager: NSObject {
    
    static let shared = HUDManager()
    
    private override init() {
    }
    
    // MARK: - Alert
    
    func showAlertView(view: UIView, backgroundColor: UIColor = .white, haptic:EKAttributes.NotificationHapticFeedback = .none ) {
        
        DispatchQueue.main.async {
            
            var attributes: EKAttributes = EKAttributes()
            attributes = .bottomFloat
            attributes.hapticFeedbackType = haptic
            attributes.displayDuration = .infinity
            attributes.screenBackground = .color(color: UIColor(white: 50.0/255.0, alpha: 0.3))
            attributes.entryBackground = .color(color: backgroundColor)
            attributes.screenInteraction = .dismiss
            attributes.entryInteraction = .forward
            attributes.roundCorners = .top(radius: 15)
            attributes.scroll = .edgeCrossingDisabled(swipeable: true)
            attributes.statusBar = .currentStatusBar
            attributes.entranceAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 0.9, initialVelocity: 0)))
            attributes.exitAnimation = .init(translate: .init(duration: 0.3))
            attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3),
                                                                scale: .init(from: 1, to: 0.8, duration: 0.3)))
            attributes.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 6))
            attributes.positionConstraints.verticalOffset = 0
            attributes.positionConstraints.size = .init(width: .offset(value: 0), height: .intrinsic)
            attributes.positionConstraints.safeArea = .empty(fillSafeArea: true)
            attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.minEdge), height: .intrinsic)
            
            
            SwiftEntryKit.display(entry: view, using: attributes)
        }
    }
    
    
    func dismiss() {
        DispatchQueue.main.async {
            SwiftEntryKit.dismiss()
        }
    }
}
