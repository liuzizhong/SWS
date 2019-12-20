
//
//  SW_RangeBottomView.swift
//  SWS
//
//  Created by jayway on 2018/5/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

enum RangeBottomBtnType {
    case last
    case sure
    case next
}

typealias RangeBottomBtnBlock = (RangeBottomBtnType)->Void

class SW_RangeBottomView: UIButton {

    @IBOutlet weak var lastStepBtn: SW_BlueButton!
    
    @IBOutlet weak var nextStepBtn: SW_BlueButton!
    
    var btnClickBlock: RangeBottomBtnBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        addTopLine()
    }
    
    func checkBtnHiddenState(informType: InformType, currentPage: RangeType, selectRange: [SW_RangeModel]) {
        switch informType {
        case .group:
            
            switch currentPage {
            case .region:
                lastStepBtn.isHidden = true
                nextStepBtn.isHidden = false
                
            case .business:
                lastStepBtn.isHidden = false
                nextStepBtn.isHidden = false
            case .department:
                lastStepBtn.isHidden = false
                nextStepBtn.isHidden = false
            case .staff:
                lastStepBtn.isHidden = false
                nextStepBtn.isHidden = true
            }
            
        case .business:
            
            switch currentPage {
            case .department:
                lastStepBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .staff:
                lastStepBtn.isHidden = false
                nextStepBtn.isHidden = true
            default:
                lastStepBtn.isHidden = true
                nextStepBtn.isHidden = true
            }
        case .department:
            
            switch currentPage {
            case .staff:
                lastStepBtn.isHidden = true
                nextStepBtn.isHidden = true
            default:
                lastStepBtn.isHidden = true
                nextStepBtn.isHidden = true
            }
            
        }
        nextStepBtn.isEnabled = selectRange.count != 0
//        sureBtn.isEnabled = selectRange.count != 0
//        let count = selectRange.reduce(0) { (rusult, model) -> Int in
//            if model.type == .staff {
//                return rusult + 1
//            } else {
//                return rusult + model.staffCount
//            }
//        }
//        sureBtn.setTitle(InternationStr("确定(\(count)人)"), for: UIControl.State())//TODO: 该处计算人数部分可以去除  也可以保留
    }
    
    func checkBtnHiddenState(rangeType: AddressBookPage, currentPage: RangeType, selectRange: [SW_RangeModel]) {
        switch rangeType {
        case .main:
            switch currentPage {
            case .region:
                lastStepBtn.isHidden = true
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .business:
                lastStepBtn.isHidden = false
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .department:
                lastStepBtn.isHidden = false
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .staff:
                lastStepBtn.isHidden = false
//                sureBtn.isHidden = false
                nextStepBtn.isHidden = true
            }
        case .region:
            switch currentPage {
            case .business:
                lastStepBtn.isHidden = true
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .department:
                lastStepBtn.isHidden = false
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .staff:
                lastStepBtn.isHidden = false
//                sureBtn.isHidden = false
                nextStepBtn.isHidden = true
            default:
                lastStepBtn.isHidden = true
                nextStepBtn.isHidden = true
//                sureBtn.isHidden = true
            }
            
        case .business:
            
            switch currentPage {
            case .department:
                lastStepBtn.isHidden = true
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = false
            case .staff:
                lastStepBtn.isHidden = false
//                sureBtn.isHidden = false
                nextStepBtn.isHidden = true
            default:
                lastStepBtn.isHidden = true
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = true
            }
        case .department:
            
            switch currentPage {
            case .staff:
                lastStepBtn.isHidden = true
//                sureBtn.isHidden = false
                nextStepBtn.isHidden = true
            default:
                lastStepBtn.isHidden = true
//                sureBtn.isHidden = true
                nextStepBtn.isHidden = true
            }
            
        }
        nextStepBtn.isEnabled = selectRange.count != 0

    }
    
     @IBAction fileprivate func lastStepBtnClick(_ sender: Any) {
        btnClickBlock?(.last)
    }
    
    @IBAction fileprivate func nextStepBtnClick(_ sender: Any) {
        btnClickBlock?(.next)
    }
    
}
