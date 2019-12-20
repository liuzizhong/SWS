//
//  SW_NormalHomeCellModel.swift
//  SWS
//
//  Created by jayway on 2019/2/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_NormalHomeCellModel: NSObject {
    
    var title = ""
    
    var icon: UIImage?
    
    var pushVc: UIViewController.Type!
    
    var describe = ""
    
    override init() {
        super.init()
    }
    
    init(title: String, icon: UIImage? = nil, describe: String = "", pushVc: UIViewController.Type) {
        super.init()
        self.title = title
        self.icon = icon
        self.describe = describe
        self.pushVc = pushVc
    }
    
}
