//
//  SW_AuditSaleContractBoutiqueFormView.swift
//  SWS
//
//  Created by jayway on 2019/8/23.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView


class SW_AuditFormBaseView: UIView, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
   
    var noDataLb: UILabel = {
        let lb = UILabel()
        lb.isHidden = true
        lb.text = "暂无数据"
        lb.textColor = UIColor.v2Color.lightGray
        lb.font = Font(14)
        lb.backgroundColor = .white
        lb.textAlignment = .center
        return lb
    }()
    
    var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    var totalHeight: CGFloat = 80
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addSubview(spreadsheetView)
        spreadsheetView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        addSubview(noDataLb)
        noDataLb.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        spreadsheetView.isScrollEnabled = true
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
        spreadsheetView.showsHorizontalScrollIndicator = false
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return 0
    }
    
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        return 0
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            return cell
        }
    }
}

class SW_AuditSaleContractBoutiqueFormView: SW_AuditFormBaseView {
    
    private var header = ["精品名称","类型","数量","零售总价","折扣%","成交总价","工时费"]
    
    let nameWidth = SCREEN_WIDTH/4 + 40
    
    var items = [SW_BoutiqueContractModel]() {
        didSet {
            if items.count > 0 {
                totalHeight = calculateCellHeight()
                spreadsheetView.isHidden = false
                noDataLb.isHidden = true
            } else {
                totalHeight = 80
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
            }
        }
    }
    
    // MARK: DataSource
    
    override func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    override func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    override func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }

    override func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch column {
        case 0:
            return nameWidth
        default:
            return 90
        }
    }
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
//            canSelectItems.count == 0   靠左   -15
        for item in items {
            if let height = item.cellHeight {
                totalHeight += height
            } else {
                let textH = max(44,item.name.heightWithConstrainedWidth(nameWidth - 15, font: Font(16)) + 24)
                item.cellHeight = textH
                totalHeight += textH
            }
        }
        return totalHeight + 35
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 44
        }
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = header[indexPath.column]
            switch indexPath.column {
            case 0:
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                return cell
            default:
                cell.setLabelAlignment(.center)
            }
            return cell
        } else {
            let model = items[indexPath.row - 1]
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            switch indexPath.column {
            case 0:
                cell.label.text = model.name
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.hourlyWageAmount.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            default:
                //             ["精品名称","类型","数量","零售总价","折扣%","成交总价","工时费"]
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = model.saleType
                case 2:
                    cell.label.text = model.count.toAmoutString()
                case 3:
                    cell.label.text = model.retailAmount.toAmoutString()
                case 4:
                    cell.label.text = model.discount.toAmoutString(places: 2)
                case 5:
                    cell.label.text = model.dealAmount.toAmoutString()
                default:
                    break
                }
                return cell
            }
        }
    }
}


class SW_AuditSaleContractOtherFormView: SW_AuditFormBaseView {
    
    private var header = ["费用名称","类型","应收金额","成本金额"]
    
    let nameWidth = SCREEN_WIDTH/4
    
    var items = [SW_OtherInfoContractItemModel]() {
        didSet {
            if items.count > 0 {
                totalHeight = calculateCellHeight()
                spreadsheetView.isHidden = false
                noDataLb.isHidden = true
            } else {
                totalHeight = 80
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
            }
        }
    }
    
    // MARK: DataSource
    
    override func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    override func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    override func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    override func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
//        switch column {
//        case 0:
            return nameWidth
//        default:
//            return 90
//        }
    }
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        //            canSelectItems.count == 0   靠左   -15
        for item in items {
            if let height = item.cellHeight {
                totalHeight += height
            } else {
                let textH = max(44,item.name.heightWithConstrainedWidth(nameWidth - 15, font: Font(16)) + 24)
                item.cellHeight = textH
                totalHeight += textH
            }
        }
        return totalHeight + 35
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 44
        }
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = header[indexPath.column]
            switch indexPath.column {
            case 0:
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                return cell
            default:
                cell.setLabelAlignment(.center)
            }
            return cell
        } else {
            let model = items[indexPath.row - 1]
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            switch indexPath.column {
            case 0:
                cell.label.text = model.name
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.costAmount.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = model.saleType
                case 2:
                    cell.label.text = model.receivableAmount.toAmoutString()
                default:
                    break
                }
                return cell
            }
        }
    }
    
}
//

class SW_AuditSaleContractInsuranceFormView: SW_AuditFormBaseView {
    
    private var header = ["保险种类","保额备注"]
    
    let nameWidth = SCREEN_WIDTH/2
    
    var items = [SW_InsuranceItemModel]() {
        didSet {
            if items.count > 0 {
                totalHeight = calculateCellHeight()
                spreadsheetView.isHidden = false
                noDataLb.isHidden = true
            } else {
                totalHeight = 80
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
            }
        }
    }
    
    // MARK: DataSource
    
    override func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    override func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    override func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    override func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return nameWidth
    }
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        //            canSelectItems.count == 0   靠左   -15
        for item in items {
            if let height = item.cellHeight {
                totalHeight += height
            } else {
                let textH = max(44,item.name.heightWithConstrainedWidth(nameWidth - 15, font: Font(16)) + 24)
                item.cellHeight = textH
                totalHeight += textH
            }
        }
        return totalHeight + 35
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 44
        }
    }
    
    override func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = header[indexPath.column]
            switch indexPath.column {
            case 0:
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                return cell
            default:
                cell.setLabelAlignment(.center)
            }
            return cell
        } else {
            let model = items[indexPath.row - 1]
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            switch indexPath.column {
            case 0:
                cell.label.text = model.name
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.insuredRemark
                cell.label.numberOfLines = 0
                return cell
            default:
                return cell
            }
        }
    }
    
}
