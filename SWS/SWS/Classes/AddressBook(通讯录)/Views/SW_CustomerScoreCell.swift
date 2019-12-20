//
//  SW_CustomerScoreCell.swift
//  SWS
//
//  Created by jayway on 2019/7/25.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_CustomerScoreCell: UITableViewCell {

    @IBOutlet weak var nameLb: UILabel!
    
    @IBOutlet weak var totalScoreLb: UILabel!
    
    @IBOutlet weak var getScoreLb: UILabel!
    
    var item: SW_CustomerScoreModel? {
        didSet {
            guard let item = item else { return }
            nameLb.text = item.name
            totalScoreLb.text = "\(item.totalScore)"
            getScoreLb.text =  item.score.toAmoutString()
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
