//
//  SW_ProgressView.swift
//  SWS
//
//  Created by jayway on 2018/11/23.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_ProgressView: UIView {

    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    // 0.0 .. 1.0, default is 0.0. values outside are pinned.
    var progress: Float = 0.0 {
        didSet {
            progressLabel.text = "\(Int(progress * 100))%"
        }
    }
    
    //    var progressTintColor: UIColor?
    //    var trackTintColor: UIColor?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.backgroundColor = UIColor.v2Color.blue
        trackView.layer.cornerRadius = 5
        progressView.layer.cornerRadius = 5
    }
    
    func setProgress(_ progress: Float, animated: Bool) {
        /// 先确保 trackview宽度正确
        self.layoutIfNeeded()
        self.progress = progress
        progressWidthConstraint.constant = trackView.width * CGFloat(progress)
        
        UIView.animate(withDuration: animated ? 0.6 : 0, delay: 0,  options: [.allowUserInteraction, .curveEaseInOut], animations: {
//            if progress >= 0.8 {
//                self.progressView.backgroundColor = #colorLiteral(red: 0, green: 0.6352941176, blue: 0.03137254902, alpha: 1)
//            } else if progress >= 0.6 {
//                self.progressView.backgroundColor = #colorLiteral(red: 0.8941176471, green: 0.7607843137, blue: 0, alpha: 1)
//            } else {
//                self.progressView.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
//            }
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
}
