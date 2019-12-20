//
//  SW_AfterSaleCustomerRecordHeader.swift
//  SWS
//
//  Created by jayway on 2019/2/26.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AfterSaleCustomerRecordHeader: Cell<AfterSaleCustomerRecordType>, CellType {
    
    @IBOutlet weak var accessBtn: QMUIButton!
    
    @IBOutlet weak var repairOrderBtn: QMUIButton!
    
    @IBOutlet weak var moreBtn: UIButton!
    
    var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.v2Color.blue
        return view
    }()
    
    private var rowForCell : SW_AfterSaleCustomerRecordHeaderRow? {
        return row as? SW_AfterSaleCustomerRecordHeaderRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(bottomLine)
        accessBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        repairOrderBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        moreBtn.setTitleColor(UIColor.v2Color.blue, for: UIControl.State())
        setupBottomLine(false)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func accessBtnClick(_ sender: QMUIButton) {
        guard row.value != .access else { return }
        row.value = .access
        rowForCell?.typeChangeBlock?(row.value!)
    }
    
    @IBAction func repairOrderBtnClick(_ sender: QMUIButton) {
        guard row.value != .repairOrder else { return }
        row.value = .repairOrder
        rowForCell?.typeChangeBlock?(row.value!)
    }
    
    private func setupBottomLine(_ animated: Bool = true) {
        let sender = row.value == .access ? accessBtn : repairOrderBtn
        accessBtn.isSelected = false
        repairOrderBtn.isSelected = false
        sender!.isSelected = true
        bottomLine.snp.removeConstraints()
        bottomLine.snp.makeConstraints { (make) in
            make.leading.equalTo(sender!.snp.leading)
            make.trailing.equalTo(sender!.snp.trailing)
            make.top.equalTo(sender!.snp.bottom)
//            make.bottom.equalToSuperview()
            make.height.equalTo(2)
        }
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: .allowUserInteraction, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    @IBAction func moreActionClick(_ sender: UIButton) {
        rowForCell?.moreBlock?()
    }
    
}

final class SW_AfterSaleCustomerRecordHeaderRow: Row<SW_AfterSaleCustomerRecordHeader>, RowType {
    
    var typeChangeBlock: ((AfterSaleCustomerRecordType)->Void)?
    
    var moreBlock: NormalBlock?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AfterSaleCustomerRecordHeader>(nibName: "SW_AfterSaleCustomerRecordHeader")
    }
}

