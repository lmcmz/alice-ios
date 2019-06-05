//
//  BasicControl.swift
//  BB-Driver
//
//  Created by lmcmz on 10/5/19.
//  Copyright © 2019 BBchuxing. All rights reserved.
//

import UIKit

class BasicControl: UIControl {
    
    @IBInspectable var highlightColor: UIColor?
    var normalColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initDefaultValue()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initDefaultValue()
    }
    
    func initDefaultValue() {
        normalColor = backgroundColor
        highlightColor = UIColor(hex: "0xD9D9D9")
    }
    
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? self.highlightColor : self.normalColor
        }
    }
}
