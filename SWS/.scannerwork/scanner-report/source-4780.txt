//
//  SW_BlueButton.swift
//  SWS
//
//  Created by jayway on 2018/4/9.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_BlueButton: QMUIButton {
    
    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            super.isEnabled = newValue
            setUpAlpha()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBtn()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBtn()
    }
    
    func setupBtn() {
        self.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: UIControl.State())
        self.setBackgroundImage(UIImage(color: UIColor(hexString: "#267cc4")), for: .highlighted)
//        self.setBackgroundImage(UIImage(color: UIColor.v2Color.blue), for: .disabled)
        self.setTitleColor(UIColor.white, for: UIControl.State())
        self.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        self.titleLabel?.font = Font(16)
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        setUpAlpha()
    }
    
    private func setUpAlpha() {
        self.alpha = isEnabled ? 1 : 0.5
    }
}


