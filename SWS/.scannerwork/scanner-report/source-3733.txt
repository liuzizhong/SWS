//
//  SW_RepairOrderRecordDetailFormCell.swift
//  SWS
//
//  Created by jayway on 2019/9/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import Eureka

class SW_RepairOrderRecordDetailItemFormCell: Cell<[SW_RepairOrderItemModel]>, CellType {
    
    var formView = SW_RepairOrderRecordDetailItemFormView()
    
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

final class SW_RepairOrderRecordDetailItemFormRow: Row<SW_RepairOrderRecordDetailItemFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}



class SW_RepairOrderRecordDetailAccessoriesFormCell: Cell<[SW_RepairOrderAccessoriesModel]>, CellType {
    
    var formView = SW_RepairOrderRecordDetailAccessoriesFormView()
    
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

final class SW_RepairOrderRecordDetailAccessoriesFormRow: Row<SW_RepairOrderRecordDetailAccessoriesFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_RepairOrderRecordDetailBoutiquesFormCell: Cell<[SW_RepairOrderBoutiquesModel]>, CellType {
    
    var formView = SW_RepairOrderRecordDetailBoutiquesFormView()
    
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

final class SW_RepairOrderRecordDetailBoutiquesFormRow: Row<SW_RepairOrderRecordDetailBoutiquesFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_RepairOrderRecordDetailOtherFormCell: Cell<[SW_RepairOrderOtherInfoModel]>, CellType {
    
    var formView = SW_RepairOrderRecordDetailOtherFormView()
    
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

final class SW_RepairOrderRecordDetailOtherFormRow: Row<SW_RepairOrderRecordDetailOtherFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_RepairOrderRecordDetailCouponsFormCell: Cell<[SW_RepairOrderCouponsModel]>, CellType {
    
    var formView = SW_RepairOrderRecordDetailCouponsFormView()
    
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

final class SW_RepairOrderRecordDetailCouponsFormRow: Row<SW_RepairOrderRecordDetailCouponsFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}


class SW_RepairOrderRecordDetailSuggestFormCell: Cell<[SW_SuggestItemInfoModel]>, CellType {
    
    var formView = SW_RepairOrderRecordDetailSuggestFormView()
    
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

final class SW_RepairOrderRecordDetailSuggestFormRow: Row<SW_RepairOrderRecordDetailSuggestFormCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
