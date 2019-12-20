//
//  SW_RevenueReportListCell.swift
//  SWS
//
//  Created by jayway on 2018/6/22.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_RevenueReportListCell: UITableViewCell {

    /// 部门
    @IBOutlet weak var depLabel: UILabel!
    
    /// 订单编号
    @IBOutlet weak var reportNumLabel: UILabel!
    
    /// 订单署期
    @IBOutlet weak var periodLabel: UILabel!
    
    /// 记录日期
    @IBOutlet weak var recordDateLabel: UILabel!
    
    @IBOutlet weak var reportNumLabelTopCon: NSLayoutConstraint!
    
    var reportModel: SW_RevenueReportModel? {
        didSet {
            guard let reportModel = reportModel else { return }
            depLabel.text = reportModel.fromDeptName
            reportNumLabel.text = "订单编号：" + reportModel.reportNo
            periodLabel.text = "订单署期：" + reportModel.reportDateString
            recordDateLabel.text = "记录日期：" + reportModel.reportCreateDateString
            if reportModel.type == .dayOrder || reportModel.type == .dayNonOrder {
                reportNumLabelTopCon.constant = 41
            } else {
                reportNumLabelTopCon.constant = 14
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
