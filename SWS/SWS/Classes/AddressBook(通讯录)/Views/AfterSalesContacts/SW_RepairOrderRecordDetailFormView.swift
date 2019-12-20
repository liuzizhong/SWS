//
//  SW_RepairOrderRecordDetailFormView.swift
//  SWS
//
//  Created by jayway on 2019/9/20.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_RepairOrderRecordDetailItemFormView: SW_AuditFormBaseView {
    
    private var header = ["项目编号","维修项目","工时","工时费","折扣%","折后工时费","班组","备注"]
    
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
        if column == 1  || column == 5 || column == 6 || column == 7 {
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
                var cHeight = max(item.remark.heightWithConstrainedWidth(nameWidth-15, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)/// 还要计算备注的高度
                cHeight = max(cHeight, item.afterSaleGroupName.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)
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
            cell.isAdd = false
            switch indexPath.column {
            case 0:
                cell.label.text = model.repairItemNum
                cell.isAdd = model.isAppend
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
                    cell.label.text = model.workingHours.toAmoutString()
                case 3:
                    cell.label.text = model.hourlyWageAmount.toAmoutString()
                case 4:
                    cell.label.text =  isCombined ? "" : model.discount.toAmoutString(places: 2)
                case 5:
                    cell.label.text = model.hourlyWageDealAmount.toAmoutString()
                case 6:
                    cell.label.text = model.afterSaleGroupName
                default:
                    break
                }
                return cell
            }
        }
    }
    
}

class SW_RepairOrderRecordDetailAccessoriesFormView: SW_AuditFormBaseView {
    
    private var header = ["配件编号","配件名称","数量","折前总价","折扣%","折后总价","增项"]
    
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
        if column == 1 || column == 6 {
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
                let cHeight = max(item.afterSaleGroupName.heightWithConstrainedWidth(nameWidth-15, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)
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
                cell.label.text = model.accessoriesNum
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.afterSaleGroupName
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                //    ["配件编号","配件名称","数量","折前总价","折扣%","折后总价","增项"]
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.name
                case 2:
                    cell.label.text = model.saleCount.toAmoutString()
                case 3:
                    cell.label.text = model.retailAmount.toAmoutString()
                case 4:
                    cell.label.text =  isCombined ? "" : model.discount.toAmoutString(places: 2)
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

class SW_RepairOrderRecordDetailBoutiquesFormView: SW_AuditFormBaseView {
    
    private var header = ["精品编号","精品名称","数量","折前总价","折扣%","折后总价","总工时费"]
    
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
        if column == 1 {
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
                cell.label.text = model.boutiqueNum
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.hourlyWageAmount.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.name
                case 2:
                    cell.label.text = model.saleCount.toAmoutString()
                case 3:
                    cell.label.text = model.retailAmount.toAmoutString()
                case 4:
                    cell.label.text =  isCombined ? "" : model.discount.toAmoutString(places: 2)
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

class SW_RepairOrderRecordDetailOtherFormView: SW_AuditFormBaseView {
    
    private var header = ["费用名称","应收金额","备注"]
    
    let nameWidth = SCREEN_WIDTH/3
    
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
//        if column == 1 {
//            return 100
//        }
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
                let cHeight = max(item.remark.heightWithConstrainedWidth(nameWidth-15, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth-15, font: Font(16)) + 24)/// 还要计算备注的高度
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
            let model = items[indexPath.row - 1]
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            switch indexPath.column {
            case 0:
                cell.label.text = model.name
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case 1:
                cell.setLabelAlignment(.center)
                cell.label.text = model.receivableAmount.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            case header.count - 1:
                cell.label.text = model.remark
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.right)
                return cell
            default:
                return cell
            }
        }
    }
    
}

class SW_RepairOrderRecordDetailCouponsFormView: SW_AuditFormBaseView {
    
    private var header = ["批次","优惠券名称","单次抵扣","有效期","备注"]
    
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
        if column == 2 || column == 2 {
            return 110
        }
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
                var cHeight = max(item.remark.heightWithConstrainedWidth(nameWidth-15, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)/// 还要计算备注的高度
                cHeight = max(cHeight, item.batchNo.heightWithConstrainedWidth(nameWidth-15, font: Font(16)) + 24)
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
            let model = items[indexPath.row - 1]
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            switch indexPath.column {
            case 0:
                cell.label.text = model.batchNo
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
                    cell.label.text = model.name
                case 2:
                    cell.label.text = model.deductibleAmount.toAmoutString()
                case 3:
                    cell.label.text = model.expDate == 0 ? "" : Date.dateWith(timeInterval: model.expDate).stringWith(formatStr: "yyyy.MM.dd")
                default:
                    break
                }
                return cell
            }
        }
    }
    
}


class SW_RepairOrderRecordDetailSuggestFormView: SW_AuditFormBaseView {
    
    private var header = ["项目编号","项目名称","类别","零售价"]
    
    let nameWidth = SCREEN_WIDTH/4 + 30
    
    var items = [SW_SuggestItemInfoModel]() {
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
//        if column == 1 {
            return nameWidth
//        } else {
//            return 110
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
                var cHeight = max(item.projectNum.heightWithConstrainedWidth(95, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(nameWidth, font: Font(16)) + 24)/// 还要计算备注的高度
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
                cell.label.text = model.projectNum
                cell.label.numberOfLines = 0
                cell.setLabelAlignment(.left)
                return cell
            case header.count - 1:
                cell.setLabelAlignment(.right)
                cell.label.text = model.retailPrice.toAmoutString()
                cell.label.numberOfLines = 0
                return cell
            default:
                cell.setLabelAlignment(.center)
                cell.label.numberOfLines = 0
                switch indexPath.column {
                case 1:
                    cell.label.text = isCombined ? "" : model.name
                case 2:
                    cell.label.text = isCombined ? "" : model.itemType.rawString
                default:
                    break
                }
                return cell
            }
        }
    }
}
