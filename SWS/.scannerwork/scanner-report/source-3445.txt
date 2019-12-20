//
//  SW_WorkTypeDetailCell.swift
//  SWS
//
//  Created by jayway on 2018/7/13.
//  Copyright © 2018年 yuanrui. All rights reserved.
//

import Eureka

class SW_WorkTypeDetailCell: Cell<[String]>, CellType {
    
    var cacheLabels = [UILabel]()
    
    var dateLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        lb.font = MediumFont(12)
        return lb
    }()
    
    var titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        lb.text = "任务标签"
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
        
        setUpSubview()
    }
    
    private func setUpSubview() {
        removeAllSubviews()///添加前将所有子view移除
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(2)
            make.leading.equalTo(15)
        }
        
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.leading.equalTo(15)
        }
        var lastLabel = titleLabel
        var lastCellFrame = CGRect.zero
        if let value = row.value, value.count > 0 {
            
            let topMargin: CGFloat = 20
            let leftRightMargin: CGFloat = 15
            let margin: CGFloat = 9
            
            for index in 0..<value.count {
                let label = creatLabel()
                label.text = value[index]
                //计算label的大小
                let itemSize = CGSize(width: min(value[index].size(Font(14), width: 0).width + 32, SCREEN_WIDTH - leftRightMargin * 2), height: 39)
                
                var frame: CGRect
                if index == 0 {
                    frame = CGRect(x: leftRightMargin, y: topMargin, width: itemSize.width, height: itemSize.height)
                } else {
                    frame = CGRect(x: lastCellFrame.maxX + margin, y: lastCellFrame.origin.y, width: itemSize.width, height: itemSize.height)
                    if frame.maxX + leftRightMargin > SCREEN_WIDTH - leftRightMargin * 2 {
                        frame = CGRect(x: leftRightMargin, y: lastCellFrame.maxY + margin, width: itemSize.width, height: itemSize.height)
                    }
                }
                addSubview(label)
                label.snp.makeConstraints { (make) in
                    make.leading.equalTo(frame.origin.x)
                    make.top.equalTo(titleLabel.snp.bottom).offset(frame.origin.y)
                    make.width.equalTo(itemSize.width)
                    make.height.equalTo(39)
                }
                
                lastCellFrame = frame
                lastLabel = label
            }
        }
        
        let line = UIView()
        line.backgroundColor = UIColor.mainColor.separator
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(lastLabel.snp.bottom).offset(15)
            make.bottom.equalTo(0)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(SingleLineWidth)
        }
    }
    
    private func creatLabel() -> UILabel {
        if let index = cacheLabels.index(where: { return $0.superview == nil }) {
            return cacheLabels[index]
        } else {
            let lb = UILabel()
            lb.font = Font(14)
            lb.textColor = UIColor.white
            lb.backgroundColor = UIColor.v2Color.blue
            lb.textAlignment = .center
            lb.layer.masksToBounds = true
            lb.layer.cornerRadius = 3
            cacheLabels.append(lb)
            return lb
        }
    }
    
}

final class SW_WorkTypeDetailRow: Row<SW_WorkTypeDetailCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
