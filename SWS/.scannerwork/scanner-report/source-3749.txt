//
//  extension_NSMutableAttributedString.swift
//  Browser
//
//  Created by 史晓义 on 2018/2/22.
//  Copyright © 2018年 114la.com. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func add(str:String,dic:[NSAttributedString.Key : Any]) {
        let attStr = NSAttributedString.init(string: str, attributes: dic)
        self.append(attStr)
    }
}











