//
//  extension_UIAlertController.swift
//  SWS
//
//  Created by jayway on 2018/5/27.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Foundation


extension UIAlertController {
    
    func clearTextFieldBorder() {
        guard let textFields = self.textFields else { return }
        for textField in textFields {
            let container = textField.superview
            let effectView = container?.superview?.subviews.first
            if effectView != nil && effectView is UIVisualEffectView {
                effectView?.removeFromSuperview()
                container?.backgroundColor = .clear
            }
        }//_UITextFieldRoundedRectBackgroundViewNeue
    }
    
    
}
