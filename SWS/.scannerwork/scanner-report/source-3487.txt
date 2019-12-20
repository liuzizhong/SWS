//
//  SW_StatisticalNavTitleView.swift
//  SWS
//
//  Created by jayway on 2018/7/25.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_StatisticalNavTitleView: UIButton {
    
    private var titleView: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.mainColor.darkBlack
        lb.font = Font(17)
        lb.textAlignment = .center
        return lb
    }()
    
    private var arrowImageView: UIImageView = {
        let imageV = UIImageView(image: #imageLiteral(resourceName: "statistical_dropdown"))
        return imageV
    }()
    
//    private var isDown = true
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 200, height: 44)
    }
    
    var navDidClickBlock: NormalBlock?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.width = 250
        self.height = 44
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {//点击手势
//        isUserInteractionEnabled = true
//        addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
//
//        })
        addTarget(self, action: #selector(titleDidClick(_:)), for: .touchUpInside)
        
        addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        addSubview(arrowImageView)
        arrowImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }
    }
    
    /// 改变title箭头方向
    ///
    /// - Parameters:
    ///   - timeInterval: 动画时长
    ///   - isToDown: 是否向下
    func changeArrowDirection(timeInterval: TimeInterval, isToDown: Bool) {
        if isToDown {
            UIView.animate(withDuration: timeInterval, animations: {
                self.arrowImageView.transform = CGAffineTransform.identity
            })
        } else {
            UIView.animate(withDuration: timeInterval, animations: {
                self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
        }
    }

    
    func setupTitle(title: String) {
        titleView.text = title
    }
    
    @objc private func titleDidClick(_ sender: UIButton) {
        self.navDidClickBlock?()
    }
}
