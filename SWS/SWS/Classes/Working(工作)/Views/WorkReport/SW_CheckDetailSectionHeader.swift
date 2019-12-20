//
//  SW_CheckDetailSectionHeader.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_CheckDetailSectionHeader: UIView {
    
    var title: String = "" {
        didSet {
            titleView.text = title
        }
    }
    
    var titleView: UILabel = {
        let lb = UILabel()
        lb.font = Font(13)
        lb.textColor = UIColor.v2Color.lightBlack
        return lb
    }()
    
    var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    var checkCountLb: UILabel = {
        let lb = UILabel()
        lb.font = Font(12)
        lb.textColor = #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        return lb
    }()
    
    var nextImageView: UIImageView = {
        let img = UIImageView(image: #imageLiteral(resourceName: "Main_NextPage"))
        return img
    }()
    
    var nextAction: NormalBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        contentView.addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.bottom.equalTo(-5)
        }
        
//        contentView.addSubview(nextImageView)
//        nextImageView.snp.makeConstraints { (make) in
//            make.trailing.equalTo(-15)
//            make.centerY.equalTo(titleView.snp.centerY)
//        }
        
        contentView.addSubview(checkCountLb)
        checkCountLb.snp.makeConstraints { (make) in
            make.trailing.equalTo(-15)
            make.centerY.equalTo(titleView.snp.centerY)
        }
        
        contentView.addGestureRecognizer(UITapGestureRecognizer { [weak self] (gesture) in
            self?.nextAction?()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
