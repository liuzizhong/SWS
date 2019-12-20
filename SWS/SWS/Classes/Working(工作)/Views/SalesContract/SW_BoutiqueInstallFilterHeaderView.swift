//
//  SW_BoutiqueInstallFilterHeaderView.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_BoutiqueInstallFilterHeaderView: UIView {

    @IBOutlet var typeBtns: [SW_ShaDowBlueBtn]!

    var selectValueChange: ((Int)->Void)?
    
    var selectType = 1 {
        didSet {
            if selectType != oldValue {
                selectValueChange?(selectType)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setTypeBtns()
        typeBtns.forEach { [weak self] (view) in
            view.isShowCount = false
            view.blueBtn.addTarget(self, action: #selector(typeBtnsClick(_:)), for: .touchUpInside)
            view.isSelected = view.tag - 100 == self?.selectType
        }
    }
    
    @objc func typeBtnsClick(_ sender: UIButton) {
        typeBtns.forEach { [weak self] (view) in
            if view.blueBtn == sender {
                view.isSelected = true
                self?.selectType = view.tag - 100
            } else {
                view.isSelected = false
            }
        }
    }
    
    private func setTypeBtns() {
        typeBtns[0].titleLb.text = "未安装"
        typeBtns[1].titleLb.text = "已安装"
        typeBtns[2].titleLb.text = "已作废"
        typeBtns[3].titleLb.text = "全部"
    }
    
}
