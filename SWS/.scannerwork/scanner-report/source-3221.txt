//
//  SW_AuditRepairOrderFormCell.swift
//  SWS
//
//  Created by jayway on 2019/8/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_AuditRepairOrderItemFormCell: Cell<[SW_RepairOrderItemModel]>, CellType {
    
    var formView = SW_AuditRepairOrderItemFormView()
    
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

final class SW_AuditRepairOrderItemFormRow: Row<SW_AuditRepairOrderItemFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}



class SW_AuditRepairOrderAccessoriesFormCell: Cell<[SW_RepairOrderAccessoriesModel]>, CellType {
    
    var formView = SW_AuditRepairOrderAccessoriesFormView()
    
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

final class SW_AuditRepairOrderAccessoriesFormRow: Row<SW_AuditRepairOrderAccessoriesFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_AuditRepairOrderBoutiquesFormCell: Cell<[SW_RepairOrderBoutiquesModel]>, CellType {
    
    var formView = SW_AuditRepairOrderBoutiquesFormView()
    
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

final class SW_AuditRepairOrderBoutiquesFormRow: Row<SW_AuditRepairOrderBoutiquesFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_AuditRepairOrderOtherFormCell: Cell<[SW_RepairOrderOtherInfoModel]>, CellType {
    
    var formView = SW_AuditRepairOrderOtherFormView()
    
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

final class SW_AuditRepairOrderOtherFormRow: Row<SW_AuditRepairOrderOtherFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_AuditRepairOrderCouponsFormCell: Cell<[SW_RepairOrderCouponsModel]>, CellType {
    
    var formView = SW_AuditRepairOrderCouponsFormView()
    
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

final class SW_AuditRepairOrderCouponsFormRow: Row<SW_AuditRepairOrderCouponsFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_AuditRepairOrderPackageFormCell: Cell<[SW_RepairPackageItemModel]>, CellType {
    
    var formView = SW_AuditRepairOrderPackageFormView()
    
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

final class SW_AuditRepairOrderPackageFormRow: Row<SW_AuditRepairOrderPackageFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
