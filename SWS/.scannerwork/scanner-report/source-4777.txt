//
//  SW_ArrowPopLabel.swift
//  SWS
//
//  Created by jayway on 2018/9/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_ArrowPopLabel: UIView {
    var bgImageView = UIImageView(image: #imageLiteral(resourceName: "MarkerBgImage"))
    var textLabel = UILabel()
    var insets: UIEdgeInsets
    var minimumSize = CGSize(width: 90, height: 50)
    var tapBlock: NormalBlock?
    var position: CGPoint = CGPoint.zero {
        didSet {
            self.origin = CGPoint(x: position.x, y: position.y - size.height + 10)
        }
    }
    var label = "" {
        didSet {
            textLabel.text = label
            let labelSize = label.size(textLabel.font, width: SCREEN_WIDTH - 30 - insets.left - insets.right)
            self.size = CGSize(width: max(labelSize.width + insets.left + insets.right, minimumSize.width), height: max(labelSize.height + insets.top + insets.bottom, minimumSize.height))
        }
    }
    
    // 初始化方法
    required init(font: UIFont, textColor: UIColor, insets: UIEdgeInsets) {
        self.insets = insets
        super.init(frame: CGRect.zero)
        textLabel.textAlignment = .center
        textLabel.font = font
        textLabel.textColor = textColor
        addSubview(bgImageView)
        addSubview(textLabel)
        bgImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        textLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(-insets.left)
            make.trailing.equalTo(insets.right)
            make.top.equalTo(insets.top)
            make.bottom.equalTo(-insets.bottom)
        }
        addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            self?.tapBlock?()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
