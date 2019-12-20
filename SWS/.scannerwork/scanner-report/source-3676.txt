//
//  SW_CustomerSourceCell.swift
//  SWS
//
//  Created by jayway on 2018/11/8.
//  Copyright © 2018 yuanrui. All rights reserved.
//


import Eureka

class SW_CustomerSourceCell: Cell<CustomerSource>, CellType {
    
    @IBOutlet weak var souceBtn: UIButton!
    
    @IBOutlet weak var webBtn: UIButton!
    
    var soucePlaceholder = "点击选择客户来源"
    
    var sitePlaceholder = "点击选择网站"

    private var rowForCell : SW_CustomerSourceRow? {
        return row as? SW_CustomerSourceRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        
        setupState()
    }
    
    @IBAction func sourceBtnClick(_ sender: UIButton) {
        rowForCell?.sourceBtnClickBlock?()
    }
    
    @IBAction func siteBtnClick(_ sender: UIButton) {
        rowForCell?.siteBtnClickBlock?()
    }
    
    func setupState() {
        if let value = row.value, value != .none {// 有选择内容
            souceBtn.setTitle(value.rawString, for: UIControl.State())
            souceBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
            if value == .networkPhone {
                webBtn.isHidden = false
                if let site = rowForCell?.site, site == .none {
                    webBtn.setTitle(sitePlaceholder, for: UIControl.State())
                    webBtn.setTitleColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), for: UIControl.State())
                } else {
                    webBtn.setTitle(rowForCell?.site.rawString, for: UIControl.State())
                    webBtn.setTitleColor(UIColor.v2Color.lightBlack, for: UIControl.State())
                }
            } else {
                webBtn.isHidden = true
            }
        } else {
            souceBtn.setTitle(soucePlaceholder, for: UIControl.State())
            souceBtn.setTitleColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), for: UIControl.State())
            webBtn.isHidden = true
        }
    }
    
    public override func update() {
        super.update()
    }
    
}

final class SW_CustomerSourceRow: Row<SW_CustomerSourceCell>, RowType {
    
    var site = CustomerSourceSite.none
    
    var sourceBtnClickBlock: NormalBlock?
    
    var siteBtnClickBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_CustomerSourceCell>(nibName: "SW_CustomerSourceCell")
    }
    
}
