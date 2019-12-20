//
//  SW_StaffInfoTypeHeader.swift
//  SWS
//
//  Created by jayway on 2018/11/17.
//  Copyright © 2018 yuanrui. All rights reserved.
//

import Eureka

class SW_StaffInfoTypeHeader: Cell<StaffInfoType>, CellType {
    
    @IBOutlet weak var workBtn: QMUIButton!
    
    @IBOutlet weak var persionBtn: QMUIButton!
    
    var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.v2Color.blue
        return view
    }()
    
    private var rowForCell : SW_StaffInfoTypeHeaderRow? {
        return row as? SW_StaffInfoTypeHeaderRow
    }
    
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(bottomLine)
        workBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        persionBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        setupBottomLine(false)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func workBtnClick(_ sender: QMUIButton) {
        guard row.value != .work else { return }
        row.value = .work
        rowForCell?.typeChangeBlock?(row.value!)
//        setupBottomLine()
    }
    
    @IBAction func persionBtnClick(_ sender: QMUIButton) {
        guard row.value != .personal else { return }
        row.value = .personal
        rowForCell?.typeChangeBlock?(row.value!)
//        setupBottomLine()
    }
    
    
    private func setupBottomLine(_ animated: Bool = true) {
        let sender = row.value == .work ? workBtn : persionBtn
        workBtn.isSelected = false
        persionBtn.isSelected = false
        sender!.isSelected = true
        bottomLine.snp.removeConstraints()
        bottomLine.snp.makeConstraints { (make) in
            make.leading.equalTo(sender!.snp.leading)
            make.trailing.equalTo(sender!.snp.trailing)
            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: .allowUserInteraction, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
}

final class SW_StaffInfoTypeHeaderRow: Row<SW_StaffInfoTypeHeader>, RowType {
    
     var typeChangeBlock: ((StaffInfoType)->Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_StaffInfoTypeHeader>(nibName: "SW_StaffInfoTypeHeader")
    }
}

