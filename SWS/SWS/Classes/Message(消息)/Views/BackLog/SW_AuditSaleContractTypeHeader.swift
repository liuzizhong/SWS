//
//  SW_AuditSaleContractTypeHeader.swift
//  SWS
//
//  Created by jayway on 2019/8/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AuditSaleContractTypeHeader: Cell<AuditSaleContractPageType>, CellType {

    @IBOutlet weak var boutiqueBtn: QMUIButton!
    
    @IBOutlet weak var otherBtn: QMUIButton!
    
    @IBOutlet weak var insuranceBtn: QMUIButton!
    
    var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.v2Color.blue
        return view
    }()
    
    private var rowForCell : SW_AuditSaleContractTypeHeaderRow? {
        return row as? SW_AuditSaleContractTypeHeaderRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(bottomLine)
        boutiqueBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        otherBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        insuranceBtn.setTitleColor(UIColor.v2Color.blue, for: .selected)
        setupBottomLine(false)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func boutiqueBtnClick(_ sender: QMUIButton) {
        guard row.value != .boutique else { return }
        row.value = .boutique
        rowForCell?.typeChangeBlock?(row.value!)
        //        setupBottomLine()
    }
    
    @IBAction func otherBtnClick(_ sender: QMUIButton) {
        guard row.value != .other else { return }
        row.value = .other
        rowForCell?.typeChangeBlock?(row.value!)
        //        setupBottomLine()
    }
    
    @IBAction func insuranceBtnClick(_ sender: QMUIButton) {
        guard row.value != .insurance else { return }
        row.value = .insurance
        rowForCell?.typeChangeBlock?(row.value!)
        //        setupBottomLine()
    }
    
    private func setupBottomLine(_ animated: Bool = true) {
        guard let type = row.value else { return }
        var sender = boutiqueBtn
        switch type {
        case .boutique:
            sender = boutiqueBtn
        case .other:
            sender = otherBtn
        case .insurance:
            sender = insuranceBtn
        }
        boutiqueBtn.isSelected = false
        otherBtn.isSelected = false
        insuranceBtn.isSelected = false
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

final class SW_AuditSaleContractTypeHeaderRow: Row<SW_AuditSaleContractTypeHeader>, RowType {
    
    var typeChangeBlock: ((AuditSaleContractPageType)->Void)?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AuditSaleContractTypeHeader>(nibName: "SW_AuditSaleContractTypeHeader")
    }
}


