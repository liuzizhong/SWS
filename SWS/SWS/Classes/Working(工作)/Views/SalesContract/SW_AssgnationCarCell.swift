//
//  SW_AssgnationCarCell.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AssgnationCarCell: Cell<SW_CarInfoModel>, CellType {
    
    @IBOutlet weak var vinLb: UILabel!

    @IBOutlet weak var colorLb: UILabel!

    @IBOutlet weak var inStockDayLb: UILabel!
    
    @IBOutlet weak var boutiqueCountLb: UILabel!
    
    @IBOutlet weak var assgnationBtn: UIButton!
    
    private var rowForCell : SW_AssgnationCarRow? {
        return row as? SW_AssgnationCarRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        assgnationBtn.layer.borderWidth = 0.5
        assgnationBtn.layer.cornerRadius = 3
        
        setupData()
    }
    
    public override func update() {
        super.update()
        setupData()
    }
    
    private func setupData() {
        guard let rowForCell = rowForCell, let value = row.value else { return }
        
        vinLb.text = value.vin
        colorLb.text = value.upholsteryColor
        inStockDayLb.text = "\(value.inStockDays)"
        boutiqueCountLb.text = value.concretePlayCarBoutiqueOutCount.toAmoutString()
        if value.assignationState == 2 {
            /// 这俩车已分配
            assgnationBtn.setTitle("取消分配", for: UIControl.State())
            assgnationBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
            assgnationBtn.isEnabled = true
            
        } else {/// 未分配
            assgnationBtn.setTitle("分配", for: UIControl.State())
            /// 本单已分配车辆|| 展车精品不为0  则不可以点击
            if rowForCell.hasAssgnation || value.concretePlayCarBoutiqueOutCount != 0 {
                assgnationBtn.layer.borderColor = UIColor.v2Color.disable.cgColor
                assgnationBtn.isEnabled = false
            } else {
                assgnationBtn.layer.borderColor = UIColor.v2Color.blue.cgColor
                assgnationBtn.isEnabled = true
            }
        }
    }
    
    
    @IBAction func assgnationBtnClick(_ sender: UIButton) {
        rowForCell?.assgnationBlock?()
    }
    
}

final class SW_AssgnationCarRow: Row<SW_AssgnationCarCell>, RowType {
    
    /// 本单是否有分配车辆
    var hasAssgnation = false
    
    var assgnationBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AssgnationCarCell>(nibName: "SW_AssgnationCarCell")
    }
}

