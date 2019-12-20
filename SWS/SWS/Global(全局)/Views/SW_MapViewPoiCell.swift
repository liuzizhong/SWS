//
//  SW_MapViewPoiCell.swift
//  SWS
//
//  Created by jayway on 2019/1/15.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_MapViewPoiCell: UITableViewCell {

    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var addressLb: UILabel!
    
    @IBOutlet weak var selectImgView: UIImageView!
    
    @IBOutlet weak var nameLbTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLbRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var addressLbRightConstraint: NSLayoutConstraint!
    
    var isHeader = false {
        didSet {
            addressLb.isHidden = isHeader
            nameLbTopConstraint.constant = isHeader ? 18 : 8
        }
    }
    var isSelect = false {
        didSet {
            selectImgView.isHidden = !isSelect
            nameLbRightConstraint.constant = isSelect ? 40 : 10
            addressLbRightConstraint.constant = isSelect ? 40 : 10
        }
    }
    var keyword = ""
    
    var poi: AMapPOI? {
        didSet {
            guard let poi = poi else {
                nameLb.text = ""
                return
            }
            
            nameLb.attributedText = NSString(string:poi.name).mutableAttributedString(keyword, andColor: UIColor.v2Color.blue, andSeparator: true)
            addressLb.attributedText = NSString(string:poi.province + poi.city + poi.district + poi.address).mutableAttributedString(keyword, andColor: UIColor.v2Color.blue, andSeparator: true)//poi.province + poi.city + poi.district + poi.address
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
