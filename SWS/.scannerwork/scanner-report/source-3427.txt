//
//  SW_ReceiveWorkReportSectionHeaderView.swift
//  SWS
//
//  Created by jayway on 2019/1/17.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_ReceiveWorkReportSectionHeaderView: UIView {
    
    @IBOutlet weak var sectionTitleLb: UILabel!
    
    @IBOutlet weak var stateImageView: UIImageView!
    
    /// 展开状态  false 收起  true 展开
    var state = false {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.stateImageView.transform = CGAffineTransform.init(rotationAngle: self.state ? -CGFloat(Double.pi/2) : CGFloat(Double.pi/2))
            }
        }
    }
    
    var tapBlock: NormalBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(actionBlock: { [weak self] (gesture) in
            self?.tapBlock?()
        }))
    }
    

}
