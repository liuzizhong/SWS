//
//  SW_SeletePeopleSectionHeader.swift
//  SWS
//
//  Created by jayway on 2018/12/3.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SeletePeopleSectionHeader: UIView {

    var title: String = "" {
        didSet {
            titleLb.text = title
        }
    }
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    var selectAllActionBlock: ((Bool)->())?
    
    var peopleCount: Int? {
        didSet {
            guard let peopleCount = peopleCount else { return }
            countLb.isHidden = peopleCount == 0
            countLb.text = "(\(peopleCount)人)"
        }
    }
    
    @IBOutlet weak var countLb: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    @IBAction func selectBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        selectAllActionBlock?(sender.isSelected)
    }
    
}
