//
//  SW_DeleteSectionHeader.swift
//  SWS
//
//  Created by jayway on 2018/6/26.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import UIKit

class SW_DeleteSectionHeader: UIView {
    
    var title: String = "" {
        didSet {
            titleView.text = title
        }
    }
    
    var sectionIndex = 0
    
    var deleteActionBlock: ((Int)->Void)?
    
    lazy var titleView: UILabel = {
        let lb = UILabel()
        lb.font = Font(13)
        lb.textColor = #colorLiteral(red: 0.7450980392, green: 0.7450980392, blue: 0.7450980392, alpha: 1)
        return lb
    }()
    
    var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = Font(12)
        btn.setTitle("删除", for: UIControl.State())
        btn.setTitleColor(UIColor.mainColor.blue, for: UIControl.State())
        btn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.mainColor.background
        addSubview(titleView)
        titleView.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
        }
        addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.top.bottom.trailing.equalToSuperview()
            make.width.equalTo(55)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func deleteAction() {
        deleteActionBlock?(sectionIndex)
    }
}

