//
//  SW_SearchChatRecordsBgView.swift
//  SWS
//
//  Created by jayway on 2018/6/19.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchChatRecordsBgView: UIView {

    var dateClickBlock: NormalBlock?
    
    var picClickBlock: NormalBlock?

    @IBAction func dateBtnAction(_ sender: UIButton) {
        dateClickBlock?()
    }
    
    @IBAction func picBtnAction(_ sender: UIButton) {
        picClickBlock?()
    }
    
}
