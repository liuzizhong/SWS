//
//  SW_WorkReportContentDetailCell.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_WorkReportContentDetailCell: Cell<String>, CellType {
    
    var contentLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.mainColor.darkBlack
        lb.font = Font(16)
        lb.numberOfLines = 0
        return lb
    }()
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lb.text = "报告内容"
        lb.font = Font(13)
        return lb
    }()
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        setUpSubview()
    }
    
    public override func update() {
        super.update()
    }
    
    private func setUpSubview() {
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(20)
            make.leading.equalTo(15)
        }
        
        addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.bottom.equalTo(-15)
        }
        
        addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: SingleLineWidth)
        
    }
    
}

final class SW_WorkReportContentDetailRow: Row<SW_WorkReportContentDetailCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

