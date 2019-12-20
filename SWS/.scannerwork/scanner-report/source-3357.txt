//
//  SW_CostIncomeDetailCell.swift
//  SWS
//
//  Created by jayway on 2018/6/29.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_CostIncomeDetailCell: Cell<[CostIncomeModel]>, CellType {
    
    private var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.mainColor.gray
        lb.font = Font(14)
        lb.textAlignment = .right
        return lb
    }()
    
    private var totleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.mainColor.blue
        lb.text = "合计"
        lb.font = Font(14)
        lb.textAlignment = .left
        return lb
    }()
    
    private var amountLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.mainColor.blue
        lb.font = Font(14)
        lb.textAlignment = .right
        return lb
    }()
    
    var cacheLabels = [UILabel]()
    
    private var rowForCell : SW_CostIncomeDetailRow? {
        return row as? SW_CostIncomeDetailRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        setUpSubview()
    }
    
    public override func update() {
        super.update()
        
        setUpSubview()
    }
    
    private func setUpSubview() {
        removeAllSubviews()///添加前将所有子view移除
        guard let value = row.value, value.count > 0 else {
            return
        }
        
        addSubview(titleLabel)
        titleLabel.text = rowForCell?.rawTitle
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.top.equalTo(12)
            make.width.equalTo(62)
        }
        
        let firstRowAmountLb = creatLabel()
        firstRowAmountLb.textAlignment = .right
        firstRowAmountLb.text = "\(value[0].amount.decimalString())￥"
        addSubview(firstRowAmountLb)
        firstRowAmountLb.snp.makeConstraints { (make) in
            make.trailing.equalTo(-16)
            make.width.equalTo(110)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        var lastAmountLb = firstRowAmountLb
        
        let firstRowNameLb = creatLabel()
        firstRowNameLb.text = value[0].typeName
        addSubview(firstRowNameLb)
        firstRowNameLb.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(3)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalTo(firstRowAmountLb.snp.leading).offset(-10)
        }
        
        for index in 1..<value.count {
            let amountLb = creatLabel()
            amountLb.textAlignment = .right
            amountLb.text = "\(value[index].amount.decimalString())￥"
            addSubview(amountLb)
            amountLb.snp.makeConstraints { (make) in
                make.trailing.equalTo(-16)
                make.width.equalTo(110)
                make.top.equalTo(lastAmountLb.snp.bottom).offset(5)
            }
            lastAmountLb = amountLb
            
            let nameLb = creatLabel()
            nameLb.text = value[index].typeName
            addSubview(nameLb)
            nameLb.snp.makeConstraints { (make) in
                make.leading.equalTo(titleLabel.snp.trailing).offset(3)
                make.centerY.equalTo(amountLb.snp.centerY)
                make.trailing.equalTo(amountLb.snp.leading).offset(-10)
            }
        }
        
        amountLabel.text = "\((rowForCell?.totalAmount ?? "0").decimalString())￥"
        addSubview(amountLabel)
        amountLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(-16)
            make.top.equalTo(lastAmountLb.snp.bottom).offset(5)
            make.bottom.equalTo(-12)
            
        }
        
        addSubview(totleLabel)
        totleLabel.snp.makeConstraints { (make) in
            make.width.equalTo(50)
            make.leading.equalTo(titleLabel.snp.trailing).offset(3)
            make.centerY.equalTo(amountLabel.snp.centerY)
            make.trailing.equalTo(amountLabel.snp.leading).offset(-10)
        }
    }
    
    private func creatLabel() -> UILabel {
        if let index = cacheLabels.index(where: { return $0.superview == nil }) {
            return cacheLabels[index]
        } else {
            let lb = UILabel()
            lb.textColor = UIColor.mainColor.darkBlack
            lb.font = Font(14)
            cacheLabels.append(lb)
            return lb
        }
    }
    
}

final class SW_CostIncomeDetailRow: Row<SW_CostIncomeDetailCell>, RowType {
    /// 总金额
    var totalAmount = ""
    
    /// title
    var rawTitle = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
