//
//  SW_RepairOrderRecordDetailInfoCell.swift
//  SWS
//
//  Created by jayway on 2019/9/19.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_RepairOrderRecordDetailInfoCell: Cell<SW_RepairOrderRecordDetailModel>, CellType {
    
    @IBOutlet weak var businessTypeLb: UILabel!
    
    @IBOutlet weak var saLb: UILabel!
    
    @IBOutlet weak var payTypeLb: UILabel!
    
    @IBOutlet weak var payStateLb: UILabel!
    
    @IBOutlet weak var busineserLb: UILabel!
    
    @IBOutlet weak var repairStateLb: UILabel!
    
    @IBOutlet weak var qualityStateLb: UILabel!
    
    @IBOutlet weak var mileageLb: UILabel!
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        guard let model = row.value else { return }
        businessTypeLb.text = model.repairBusinessTypeStr.isEmpty ? "无" : model.repairBusinessTypeStr
        saLb.text = model.staffName
        payTypeLb.text = model.payTypeStr
        payStateLb.text = model.payStateStr
        busineserLb.text = model.insuranceName.isEmpty ? "无" : model.insuranceName
        repairStateLb.text = model.repairStateStr
        qualityStateLb.text = model.qualityStateStr
        mileageLb.text = "\(model.mileage)km"
    }
    
    public override func update() {
        super.update()
    }
    
}

final class SW_RepairOrderRecordDetailInfoRow: Row<SW_RepairOrderRecordDetailInfoCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_RepairOrderRecordDetailInfoCell>(nibName: "SW_RepairOrderRecordDetailInfoCell")
    }
}
