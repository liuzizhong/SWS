//
//  SW_SelectPictureCollectionViewCell.swift
//  SWS
//
//  Created by jayway on 2018/7/9.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_SelectPictureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addImageBtn: QMUIButton!
    
    @IBOutlet weak var coverView: UIView!
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var shouDownBtn: UIButton!
    
    var shouDownBlock: NormalBlock?
    
    var dottedLine: CAShapeLayer?
    
    var canShouDown = false {
        didSet {
            shouDownBtn.isHidden = !canShouDown
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        iconImageView.layer.cornerRadius = 3
//        coverView.layer.cornerRadius = 3
        addImageBtn.imagePosition = .top
        
        trackView.layer.cornerRadius = 2.5
        progressView.layer.cornerRadius = 2.5
        progressView.layer.borderColor = UIColor.white.cgColor
        progressView.layer.borderWidth = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dottedLine?.removeFromSuperlayer()
        dottedLine = addImageBtn.addDottedLine()
    }
    
    @IBAction func shouDownBtnClick(_ sender: UIButton) {
        shouDownBlock?()
    }
    
    func showOrHideProgressView(_ isHidden: Bool) {
        trackView.isHidden = isHidden
        progressView.isHidden = isHidden
    }
    
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var progressWidthConstraint: NSLayoutConstraint!
    
    // 0.0 .. 1.0, default is 0.0. values outside are pinned.
    var progress: Float = 0.0
    
    func setProgress(_ progress: Float, animated: Bool) {
        /// 先确保 trackview宽度正确
        self.layoutIfNeeded()
        self.progress = progress
        progressWidthConstraint.constant = trackView.width * CGFloat(progress)
        UIView.animate(withDuration: animated ? 0.4 : 0, delay: 0,  options: [.allowUserInteraction, .curveEaseInOut], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
    }
    
}
