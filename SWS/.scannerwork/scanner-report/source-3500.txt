//
//  SW_CarModelDataCell.swift
//  SWS
//
//  Created by jayway on 2018/8/7.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CarModelDataCell: UITableViewCell {

    @IBOutlet weak var sectionTitleBgView: UIView!
    
    @IBOutlet weak var sectionTitleLb: UILabel!
    
    @IBOutlet weak var carModelLb: UILabel!
    
    @IBOutlet weak var accountsTypeLb: UILabel!
    
    @IBOutlet weak var amountLb: UILabel!
    
    @IBOutlet weak var amountPercentLb: UILabel!
    
    var model: SW_CarModelData? {
        didSet {
            guard let model = model else { return }
            carModelLb.text = model.carBrand + " " + model.carSerie + " " + model.carModel
            accountsTypeLb.text = model.accountsType.rawTitle
            amountLb.text = model.getAmountString()
            amountPercentLb.text = model.getPercentString()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
