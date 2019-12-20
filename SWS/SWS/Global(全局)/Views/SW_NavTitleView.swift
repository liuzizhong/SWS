//
//  SW_NavTitleView.swift
//  SWS
//
//  Created by jayway on 2019/8/22.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit

class SW_NavTitleView: UIView {

    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var riightBtn: UIButton!
    
    var rightBlock: NormalBlock?
    
    var backBlock: NormalBlock?
    
    var title = "" {
        didSet {
            titleLb.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        riightBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
    }
    
    func showOrHideSubView(show: Bool, duration: TimeInterval = TabbarAnimationDuration) {
        let alpha: CGFloat = show ? 1 : 0
        
        UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
            self.backBtn.alpha = alpha
            self.titleLb.alpha = alpha
            self.riightBtn.alpha = alpha
        }, completion: nil)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        backBlock?()
    }
    
    @IBAction func rightAction(_ sender: UIButton) {
        rightBlock?()
    }
}
