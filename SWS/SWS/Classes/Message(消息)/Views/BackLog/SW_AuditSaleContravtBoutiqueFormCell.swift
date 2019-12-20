//
//  SW_AuditSaleContravtBoutiqueFormCell.swift
//  SWS
//
//  Created by jayway on 2019/8/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AuditSaleContravtBoutiqueFormCell: Cell<[SW_BoutiqueContractModel]>, CellType {
    
    var formView = SW_AuditSaleContractBoutiqueFormView()
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(formView)
        formView.items = row.value ?? []
        formView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(formView.totalHeight).priority(.medium)
        }
    }
    
    public override func update() {
        super.update()
    }
    
    
}

final class SW_AuditSaleContravtBoutiqueFormRow: Row<SW_AuditSaleContravtBoutiqueFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

class SW_AuditSaleContravtOtherFormCell: Cell<[SW_OtherInfoContractItemModel]>, CellType {
    
    var formView = SW_AuditSaleContractOtherFormView()
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(formView)
        formView.items = row.value ?? []
        formView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(formView.totalHeight).priority(.medium)
        }
    }
    
    public override func update() {
        super.update()
    }
    
    
}

final class SW_AuditSaleContravtOtherFormRow: Row<SW_AuditSaleContravtOtherFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_AuditSaleContravtInsuranceFormCell: Cell<[SW_InsuranceItemModel]>, CellType {
    
    var formView = SW_AuditSaleContractInsuranceFormView()
    
    public override func setup() {
        super.setup()
        selectionStyle = .none
        addSubview(formView)
        formView.items = row.value ?? []
        formView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalTo(formView.totalHeight).priority(.medium)
        }
    }
    
    public override func update() {
        super.update()
    }
    
}

final class SW_AuditSaleContravtInsuranceFormRow: Row<SW_AuditSaleContravtInsuranceFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
