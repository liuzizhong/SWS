//
//  SW_StartEndTimeCell.swift
//  SWS
//
//  Created by jayway on 2018/11/9.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_StartEndTimeCell: Cell<String>, CellType {
    
    @IBOutlet weak var titleLb: UILabel!
    
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var endBtn: UIButton!
    
    var placeholder = "点击选择时间"
    
    private var rowForCell : SW_StartEndTimeRow? {
        return row as? SW_StartEndTimeRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        titleLb.text = rowForCell?.rawTitle
        setupState()
    }
    
    @IBAction func startBtnClick(_ sender: UIButton) {
        rowForCell?.startBtnClickBlock?()
    }
    
    @IBAction func endBtnClick(_ sender: UIButton) {
        rowForCell?.endBtnClickBlock?()
    }
    
    func setupState() {
        if let value = row.value, !value.isEmpty {// 有选择内容
            startBtn.setTitle(value, for: UIControl.State())
            startBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        } else {
            startBtn.setTitle(placeholder, for: UIControl.State())
            startBtn.setTitleColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), for: UIControl.State())
        }
        if rowForCell?.endTime.isEmpty == true {
            endBtn.setTitle(placeholder, for: UIControl.State())
            endBtn.setTitleColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), for: UIControl.State())
        } else {
            endBtn.setTitle(rowForCell?.endTime, for: UIControl.State())
            endBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
        }
        
    }
    
    public override func update() {
        super.update()
    }
    
}

final class SW_StartEndTimeRow: Row<SW_StartEndTimeCell>, RowType {
    
    var rawTitle = ""
    
    var endTime = ""
    
    var startBtnClickBlock: NormalBlock?
    
    var endBtnClickBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_StartEndTimeCell>(nibName: "SW_StartEndTimeCell")
    }
    
}

