//
//  SW_AccessRecordListCell.swift
//  SWS
//
//  Created by jayway on 2018/11/12.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_AccessRecordListCell: Cell<SW_AccessRecordListModel>, CellType {
    
    @IBOutlet weak var topLine: UIView!
    
    @IBOutlet weak var bottomLine: UIView!
    
    @IBOutlet weak var indexLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var typeTitleLabel: UILabel!
    
    @IBOutlet weak var accessHandleLb: UILabel!
    
    @IBOutlet weak var moreImageView: UIImageView!
    
    @IBOutlet weak var accessRecordLabel: UILabel!
    
    @IBOutlet weak var complaintStateImgV: UIImageView!
    
    @IBOutlet weak var recordLbRightConstraint: NSLayoutConstraint!
    
    var complaintState: ComplaintState? {
        didSet {
            guard let complaintState = complaintState else { return }
            switch complaintState {
            case .waitAudit,.waitHandle:
                complaintStateImgV.isHidden = false
                complaintStateImgV.image = complaintState.rawImage
                recordLbRightConstraint.constant = -25
            default:
                complaintStateImgV.isHidden = true
                recordLbRightConstraint.constant = -20
            }
        }
    }
    
    private var rowForCell: SW_AccessRecordListRow? {
        return row as? SW_AccessRecordListRow
    }
//    pop_complaint_dispose
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
       
        
        indexLabel.layer.cornerRadius = 8
        indexLabel.backgroundColor = UIColor.v2Color.blue
        
        setUpValue()
    }
    
    public override func update() {
        super.update()
        setUpValue()
    }
    
    private func setUpValue() {
        if let model = row.value  {
            //            2018年6月11日 18:30 周五
            dateLabel.text = Date.dateWith(timeInterval: model.endDate).simpleTimeString(formatter: .yearMinite) + " " + model.whatDay
            complaintState = model.complaintState
            typeTitleLabel.text = model.accessType.rawString
            accessRecordLabel.text = model.accessType == .tryDrive ? model.testDriveContent : model.recordContent
        } else if let model = rowForCell?.afterSaleRecord {//售后接待记录
            dateLabel.text = Date.dateWith(timeInterval: model.endDate).simpleTimeString(formatter: .yearMinite) + " " + model.whatDay
            complaintState = .pass
            typeTitleLabel.text = model.accessType.rawString
            accessRecordLabel.text = model.recordContent
        } else if let model = rowForCell?.repairOrderRecord {///维修记录
            dateLabel.text = model.repairOrderNum
            typeTitleLabel.text = "维修单详情"
            complaintState = model.complaintState
            accessRecordLabel.text = model.completeDate == 0 ? "出厂时间:  无\n里程数:  \(model.mileage)km" : "出厂时间:  \(Date.dateWith(timeInterval: model.completeDate).simpleTimeString(formatter: .yearMinite))\n里程数:  \(model.mileage)km"
        } else if let model = rowForCell?.purchaseCarRecord {///购车记录
            complaintState = model.complaintState
            dateLabel.text = "合同编号:" + model.contractNum
            typeTitleLabel.text = "合同状态:" + model.payState.rawTitle
            accessRecordLabel.text = model.vin.isEmpty ? "车架号:  未分配\n车型信息:  \(model.car)" : "车架号:  \(model.vin)\n车型信息:  \(model.car)"
        }
    }
}

final class SW_AccessRecordListRow: Row<SW_AccessRecordListCell>, RowType {
    
    var afterSaleRecord: SW_AfterSaleAccessRecordListModel?
    
    var repairOrderRecord: SW_RepairOrderRecordListModel?
    
    var purchaseCarRecord:SW_PurchaseCarRecordListModel?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AccessRecordListCell>(nibName: "SW_AccessRecordListCell")
    }
}
