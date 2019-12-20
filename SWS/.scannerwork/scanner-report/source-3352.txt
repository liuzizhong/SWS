//
//  SW_CarInStockFilterHeaderView.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_CarInStockFilterHeaderView: UIView {
    
    @IBOutlet var typeBtns: [SW_ShaDowBlueBtn]!
    
    var totalCount = 0
    var inStockCount = 0
    var onWayCount = 0
    var onAssignationCount = 0

    var selectValueChange: ((Int)->Void)?
    
    var selectType = 0 {
        didSet {
            if selectType != oldValue {
                selectValueChange?(selectType)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        getCarCount()
        setTypeBtns()
        typeBtns.forEach { [weak self] (view) in
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
        typeBtns[0].titleLb.text = "全部"
        typeBtns[0].countLb.text = "(\(totalCount))"
        typeBtns[1].titleLb.text = "在库"
        typeBtns[1].countLb.text = "(\(inStockCount))"
        typeBtns[2].titleLb.text = "在途"
        typeBtns[2].countLb.text = "(\(onWayCount))"
        typeBtns[3].titleLb.text = "未分配"
        typeBtns[3].countLb.text = "(\(onAssignationCount))"
    }
    
    func getCarCount() {
        SW_WorkingService.getCarStockCount().response({ (json, isCache, error) in
            if let json = json as? JSON, error == nil {
                self.totalCount = json["totalCount"].intValue
                self.inStockCount = json["inStockCount"].intValue
                self.onWayCount = json["onWayCount"].intValue
                self.onAssignationCount = json["onAssignationCount"].intValue
                self.setTypeBtns()
            }
        })
    }
    
}
