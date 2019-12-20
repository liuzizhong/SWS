//
//  SW_AuditRepairOrderTypeHeader.swift
//  SWS
//
//  Created by jayway on 2019/8/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AuditRepairOrderTypeHeader: Cell<AuditRepairOrderPageType>, CellType {
    
    @IBOutlet weak var itemBtn: QMUIButton!
    @IBOutlet weak var accessoriesBtn: QMUIButton!
    @IBOutlet weak var boutiqueBtn: QMUIButton!
    @IBOutlet weak var otherBtn: QMUIButton!
    @IBOutlet weak var repairPackageBtn: QMUIButton!
    @IBOutlet weak var couponsBtn: QMUIButton!
    @IBOutlet weak var suggestBtn: QMUIButton!
    /// 添加有顺序，注意顺序
    @IBOutlet var options: [QMUIButton]!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var suggestLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var suggestWidthConstraint: NSLayoutConstraint!
    
    
    var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.v2Color.blue
        return view
    }()
    
    private var rowForCell : SW_AuditRepairOrderTypeHeaderRow? {
        return row as? SW_AuditRepairOrderTypeHeaderRow
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        scrollView.addSubview(bottomLine)
        options.forEach({ $0.setTitleColor(UIColor.v2Color.blue, for: .selected) })
        
        if rowForCell?.isHideSuggest == true {
            suggestBtn.isHidden = true
            suggestLeftConstraint.constant = 0
            suggestWidthConstraint.constant = 0
        }
        
        setupBottomLine(false, contentOffSet: CGPoint.zero)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func itemBtnClick(_ sender: QMUIButton) {
        guard row.value != .item else { return }
        row.value = .item
        rowForCell?.typeChangeBlock?(.item)
        setupBottomLine(true, contentOffSet: CGPoint.zero)
    }
    
    @IBAction func accessoriesBtnClick(_ sender: QMUIButton) {
        guard row.value != .accessories else { return }
        row.value = .accessories
        rowForCell?.typeChangeBlock?(.accessories)
        setupBottomLine(true, contentOffSet: CGPoint.zero)
    }
    
    @IBAction func boutiqueBtnClick(_ sender: QMUIButton) {
        guard row.value != .boutique else { return }
        row.value = .boutique
        rowForCell?.typeChangeBlock?(.boutique)
        setupBottomLine(true, contentOffSet: CGPoint(x: max(0, repairPackageBtn.frame.maxX + 15 - SCREEN_WIDTH), y: 0))
    }
    
    @IBAction func otherBtnClick(_ sender: QMUIButton) {
        guard row.value != .other else { return }
        row.value = .other
        rowForCell?.typeChangeBlock?(.other)
        
        setupBottomLine(true, contentOffSet: CGPoint(x: max(0, couponsBtn.frame.maxX + 15 - SCREEN_WIDTH), y: 0))
    }
    
    
    @IBAction func repairPackageBtnClick(_ sender: QMUIButton) {
        guard row.value != .repairPackage else { return }
        row.value = .repairPackage
        rowForCell?.typeChangeBlock?(.repairPackage)
        
        setupBottomLine(true, contentOffSet: CGPoint(x: max(0, suggestBtn.frame.maxX + 15 - SCREEN_WIDTH), y: 0))
    }
    
    @IBAction func couponsBtnClick(_ sender: QMUIButton) {
        guard row.value != .coupons else { return }
        row.value = .coupons
        rowForCell?.typeChangeBlock?(.coupons)
        setupBottomLine(true, contentOffSet: CGPoint(x: max(0, suggestBtn.frame.maxX + 15 - SCREEN_WIDTH), y: 0))
    }
    
    @IBAction func suggestBtnClick(_ sender: QMUIButton) {
        guard row.value != .suggest else { return }
        row.value = .suggest
        rowForCell?.typeChangeBlock?(.suggest)
        setupBottomLine(true, contentOffSet: CGPoint(x: max(0, suggestBtn.frame.maxX + 15 - SCREEN_WIDTH), y: 0))
    }
    
    
    private func setupBottomLine(_ animated: Bool = false, contentOffSet: CGPoint) {
        guard let type = row.value else { return }
        let sender = options[type.rawValue]
        options.forEach({ $0.isSelected = false })
        sender.isSelected = true
        
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: .allowUserInteraction, animations: {
            self.bottomLine.frame = CGRect(x: sender.frame.minX, y: 48, width: sender.width, height: 2)
            self.scrollView.contentOffset = contentOffSet
        }, completion: nil)
    }
}

final class SW_AuditRepairOrderTypeHeaderRow: Row<SW_AuditRepairOrderTypeHeader>, RowType {
    
    var typeChangeBlock: ((AuditRepairOrderPageType)->Void)?
    
    var isHideSuggest = true
    
    required public init(tag: String?) {
        super.init(tag: tag)
        
        // 我们把对应SW_HobbyCell的 .xib 加载到cellProvidor
        cellProvider = CellProvider<SW_AuditRepairOrderTypeHeader>(nibName: "SW_AuditRepairOrderTypeHeader")
    }
}



