//
//  SW_CarInStockListCell.swift
//  SWS
//
//  Created by jayway on 2019/11/12.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_CarInStockListCell: UITableViewCell {
  
    @IBOutlet weak var vinLb: UILabel!
    
    @IBOutlet weak var carModelLb: UILabel!
    
    @IBOutlet weak var upholsteryColorLb: UILabel!
    
    @IBOutlet weak var assignationStateLb: UILabel!
    
    @IBOutlet weak var stockStateLb: UILabel!
    
    @IBOutlet weak var inStockDayLb: UILabel!
    
    var model: SW_CarInStockListModel? {
        didSet {
            guard let model = model else { return }
            vinLb.text = model.vin
            carModelLb.text = model.carBrand + "  " + model.carSeries + "  " + model.carModel + "  " + model.carColor
            upholsteryColorLb.text = model.upholsteryColor
            assignationStateLb.text = model.assignationState == 2 ? "已分配" : "未分配"
            stockStateLb.text = model.stockState.rawTitle
            inStockDayLb.text = "\(model.inStockDays)"
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UIColor.v2Color.blue
    }
    
}
