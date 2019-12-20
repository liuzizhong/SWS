//
//  SW_AuditRepairOrderFormView.swift
//  SWS
//
//  Created by jayway on 2019/8/24.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_AuditRepairOrderItemFormView: SW_AuditFormBaseView {
    
    private var header = ["项目名称","工时","工时费","折扣%","折后工时费","维修种类","子帐"]
    
    let nameWidth = SCREEN_WIDTH/3 + 30
    
    var items = [SW_RepairOrderItemModel]() {
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
        if column == 0 {
            return nameWidth
        } else {
            return 110
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
                let cHeight = max(item.repairTypeName.heightWithConstrainedWidth(110, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)
                let textH = max(44, cHeight)/// 还要计算备注的高度
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
            let isCombined = items.count == indexPath.row
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
                cell.label.text = model.accountTypeName
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.workingHours.toAmoutString()
                case 2:
                    cell.label.text = model.hourlyWageAmount.toAmoutString()
                case 3:
                    cell.label.text =  isCombined ? "" : model.discount.toAmoutString(places: 2)
                case 4:
                    cell.label.text = model.hourlyWageDealAmount.toAmoutString()
                case 5:
                    cell.label.text = model.repairTypeName
                default:
                    break
                }
                return cell
            }
        }
    }
    
}

class SW_AuditRepairOrderAccessoriesFormView: SW_AuditFormBaseView {
    
    private var header = ["配件名称","数量","折前总价","折扣%","折后总价","维修种类","子帐"]
    
    let nameWidth = SCREEN_WIDTH/3 + 30
    
    var items = [SW_RepairOrderAccessoriesModel]() {
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
        if column == 0 {
            return nameWidth
        } else {
            return 110
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
                let cHeight = max(item.repairTypeName.heightWithConstrainedWidth(110, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)
                let textH = max(44, cHeight)
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
            let isCombined = items.count == indexPath.row
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
                cell.label.text = model.accountTypeName
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.saleCount.toAmoutString()
                case 2:
                    cell.label.text = model.retailAmount.toAmoutString()
                case 3:
                    cell.label.text =  isCombined ? "" : model.discount.toAmoutString(places: 2)
                case 4:
                    cell.label.text = model.dealAmount.toAmoutString()
                case 5:
                    cell.label.text = model.repairTypeName
                default:
                    break
                }
                return cell
            }
        }
    }
    
}

class SW_AuditRepairOrderBoutiquesFormView: SW_AuditFormBaseView {
    
    private var header = ["精品名称","数量","折前总价","折扣%","折后总价","总工时费","小计"]
    
    let nameWidth = SCREEN_WIDTH/3 + 30
    
    var items = [SW_RepairOrderBoutiquesModel]() {
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
        if column == 0 {
            return nameWidth
        } else {
            return 110
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
            let isCombined = items.count == indexPath.row
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
                cell.label.text = model.subtotal.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.saleCount.toAmoutString()
//["精品名称","数量","折前总价","折扣%","折后总价","总工时费","小计"]
                case 2:
                    cell.label.text = model.retailAmount.toAmoutString()
                case 3:
                    cell.label.text =  isCombined ? "" : model.discount.toAmoutString(places: 2)
                case 4:
                    cell.label.text = model.dealAmount.toAmoutString()
                case 5:
                    cell.label.text = model.hourlyWageAmount.toAmoutString()
                default:
                    break
                }
                return cell
            }
        }
    }
    
}

class SW_AuditRepairOrderOtherFormView: SW_AuditFormBaseView {
    
    private var header = ["费用名称","应收金额"]
    
    let nameWidth = SCREEN_WIDTH/2
    
    var items = [SW_RepairOrderOtherInfoModel]() {
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
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.receivableAmount.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            default:
                return cell
            }
        }
    }
    
}

class SW_AuditRepairOrderCouponsFormView: SW_AuditFormBaseView {
    
    private var header = ["优惠券名称","单次抵扣","有效期"]
    
    let nameWidth = SCREEN_WIDTH/3
    
    var items = [SW_RepairOrderCouponsModel]() {
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
            case header.count - 1:
//                ["优惠券名称","单次抵扣","有效期"]
                cell.setLabelAlignment(.right)
                cell.label.text = model.expDate == 0 ? "" : Date.dateWith(timeInterval: model.expDate).stringWith(formatStr: "yyyy.MM.dd")
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.text = model.deductibleAmount.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            }
        }
    }
    
}

/// 活动套餐表格
class SW_AuditRepairOrderPackageFormView: SW_AuditFormBaseView {
    
    private var header = ["活动套餐名称","套餐项目","单价","备注"]
    
    let nameWidth = SCREEN_WIDTH/3 + 30
    
    var items = [SW_RepairPackageItemModel]() {
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
        if column == 2 {
            return 110
        } else {
            return nameWidth
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
                var cHeight = max(item.remark.heightWithConstrainedWidth(nameWidth - 15, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)
                cHeight = max(cHeight, item.activityRepairPackageName.heightWithConstrainedWidth(nameWidth - 15, font: Font(16)) + 24)
                let textH = max(44, cHeight)/// 还要计算备注的高度
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
            let isCombined = items.count == indexPath.row
            let model = items[indexPath.row - 1]
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            switch indexPath.column {
            case 0:
                cell.label.text = model.activityRepairPackageName
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.remark
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.name
                case 2:
                    cell.label.text = model.retailPrice.toAmoutString()
                default:
                    break
                }
                return cell
            }
        }
    }
    
}
