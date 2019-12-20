//
//  SW_SearchHistoryHeaderView.swift
//  SWS
//
//  Created by jayway on 2018/11/21.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import UIKit

class SW_SearchHistoryHeaderView: UIView {

    var title: String = "" {
        didSet {
            titleView.text = title
        }
    }
    
    var deleteActionBlock: NormalBlock?
    
    lazy var titleView: UILabel = {
        let lb = UILabel()
        lb.font = MediumFont(14)
        lb.textColor = UIColor.v2Color.darkGray
        return lb
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "icon_garbagecan"), for: UIControl.State())
        btn.addTarget(self, action: #selector(deleteBtnClick(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleView.snp.centerY)
            make.trailing.equalTo(0)
            make.width.equalTo(60)
            make.height.equalTo(44)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 删除
    @objc private func deleteBtnClick(_ sender: UIButton) {
        deleteActionBlock?()
    }
}
