//
//  SW_SalesContractInstallListCell.swift
//  SWS
//
//  Created by jayway on 2019/11/14.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_SalesContractInstallListCell: UITableViewCell {
  
    @IBOutlet weak var vinLb: UILabel!

    @IBOutlet weak var carModelLb: UILabel!

    @IBOutlet weak var contractNumLb: UILabel!
    
    @IBOutlet weak var transactImgV: UIImageView!
    
    @IBOutlet weak var customerNameLb: UILabel!

    @IBOutlet weak var payStateLb: UILabel!

    @IBOutlet weak var preDateLb: UILabel!
    
    var model: SW_SalesContractInstallListModel? {
        didSet {
            guard let model = model else { return }
            vinLb.text = model.vin.isEmpty ? "未分配" : model.vin
            carModelLb.text = model.carBrand + "  " + model.carSeries + "  " + model.carModel + "  " + model.carColor
            customerNameLb.text = model.customerName
            contractNumLb.text = model.contractNum
            payStateLb.text = "合同状态:" + model.payState.rawTitle
            
            if model.invalidAuditState == 3 {
                transactImgV.isHidden = false
                transactImgV.image = #imageLiteral(resourceName: "work_icon_obsolete")
            } else {
                transactImgV.isHidden = !model.isInstall
                transactImgV.image = #imageLiteral(resourceName: "work_icon_Installed")
            }
            preDateLb.text = Date.dateWith(timeInterval: model.deliveryDate).stringWith(formatStr: "yyyy.MM.dd")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
}
