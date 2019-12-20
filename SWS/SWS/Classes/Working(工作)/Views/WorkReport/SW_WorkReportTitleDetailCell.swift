//
//  SW_WorkReportTitleDetailCell.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_WorkReportTitleDetailCell: Cell<String>, CellType {
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.v2Color.lightBlack
        lb.font = Font(16)
        return lb
    }()
    
    var rowNameLb: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lb.text = "标题"
        lb.font = Font(13)
        return lb
    }()
    
    var dateLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        lb.font = MediumFont(12)
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
        
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.leading.equalTo(15)
        }
        
        addSubview(rowNameLb)
        rowNameLb.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.equalTo(rowNameLb.snp.bottom).offset(15)
            make.bottom.equalTo(-15)
        }
        
        addBottomLine(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), height: SingleLineWidth)
    }
    
}

final class SW_WorkReportTitleDetailRow: Row<SW_WorkReportTitleDetailCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
