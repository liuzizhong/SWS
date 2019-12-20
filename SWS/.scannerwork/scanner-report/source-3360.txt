//
//  SW_InsuranceDetailCell.swift
//  SWS
//
//  Created by jayway on 2018/6/29.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_InsuranceDetailCell: Cell<[InsuranceModel]>, CellType {
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = UIColor.mainColor.gray
        lb.font = Font(14)
        lb.textAlignment = .right
        return lb
    }()
    
    let imageLine = UIImageView(image: #imageLiteral(resourceName: "dotted_line"))
    
    var cacheLabels = [UILabel]()
    
    private var rowForCell : SW_InsuranceDetailRow? {
        return row as? SW_InsuranceDetailRow
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
        
        addSubview(imageLine)
        imageLine.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.top.trailing.equalToSuperview()
        }
        
        addSubview(titleLabel)
        titleLabel.text = rowForCell?.rawTitle
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(16)
            make.top.equalTo(12)
            make.width.equalTo(62)
        }
        
        let firstRowDateLb = creatLabel()
        firstRowDateLb.textAlignment = .right
        firstRowDateLb.text = "\(Date.dateWith(timeInterval: value[0].limitDate).stringWith(formatStr: "yyyy.MM.dd"))到期"
        addSubview(firstRowDateLb)
        firstRowDateLb.snp.makeConstraints { (make) in
            make.trailing.equalTo(-16)
            make.width.equalTo(110)
            make.centerY.equalTo(titleLabel.snp.centerY)
        }
        var lastDateLb = firstRowDateLb
        
        let firstRowNameLb = creatLabel()
        firstRowNameLb.text = value[0].insuranceTypeName
        addSubview(firstRowNameLb)
        firstRowNameLb.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(3)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.trailing.equalTo(firstRowDateLb.snp.leading).offset(-10)
        }
        
        for index in 1..<value.count {
            let dateLb = creatLabel()
            dateLb.textAlignment = .right
            dateLb.text = "\(Date.dateWith(timeInterval: value[index].limitDate).stringWith(formatStr: "yyyy.MM.dd"))到期"
            addSubview(dateLb)
            dateLb.snp.makeConstraints { (make) in
                make.trailing.equalTo(-16)
                make.width.equalTo(110)
                make.top.equalTo(lastDateLb.snp.bottom).offset(5)
            }
            lastDateLb = dateLb
            
            let nameLb = creatLabel()
            nameLb.text = value[index].insuranceTypeName
            addSubview(nameLb)
            nameLb.snp.makeConstraints { (make) in
                make.leading.equalTo(titleLabel.snp.trailing).offset(3)
                make.centerY.equalTo(dateLb.snp.centerY)
                make.trailing.equalTo(dateLb.snp.leading).offset(-10)
            }
        }
        
        subviews.last!.snp.remakeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(3)
            make.centerY.equalTo(lastDateLb.snp.centerY)
            make.trailing.equalTo(lastDateLb.snp.leading).offset(-10)
            make.bottom.equalTo(-12)
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

final class SW_InsuranceDetailRow: Row<SW_InsuranceDetailCell>, RowType {
    
    var rawTitle = ""
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
