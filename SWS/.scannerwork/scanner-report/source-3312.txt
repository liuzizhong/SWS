//
//  SW_OrderItemFormViewController.swift
//  SWS
//
//  Created by jayway on 2019/6/13.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_OrderItemFormViewController: SW_BaseFormViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    var isInvalid = false
    var header = ["项目编号","项目名称","工时","班组","工位","项目状态"]
    var items = [SW_RepairOrderItemModel]() {
        didSet {
            if items.count > 0 {
                if isInvalid {
                    canSelectItems = []
                } else {
                    canSelectItems = items.filter({ return ($0.qualityState == .noCommit || $0.qualityState == .unqualified) && $0.state == 1 })
                }
                let totalHeight = calculateCellHeight()
                spreadsheetView.isHidden = false
                spreadsheetView.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: totalHeight)
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(74 + TABBAR_BOTTOM_INTERVAL + max(totalHeight, SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 94 - TABBAR_BOTTOM_INTERVAL)))
                noDataLb.isHidden = true
            } else {
                canSelectItems = []
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 40))
            }
            selectItems = []
            spreadsheetView.reloadData()
            //            dispatch_delay(0.1) {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: -self.scrollView.contentInset.top), animated: false)
            //            }
        }
    }
    
    var selectItems = [SW_RepairOrderItemModel]()
    
    var canSelectItems = [SW_RepairOrderItemModel]()
    
    var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    private func setup() {
        scrollView.addSubview(spreadsheetView)
//        spreadsheetView.frame = view.bounds
//        scrollView.contentSize = view.bounds.size
        spreadsheetView.frame.origin.y = 20
        spreadsheetView.isScrollEnabled = true
        spreadsheetView.showsHorizontalScrollIndicator = false
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
        spreadsheetView.register(SelectHeaderCell.self, forCellWithReuseIdentifier: String(describing: SelectHeaderCell.self))
        spreadsheetView.register(SelectTextCell.self, forCellWithReuseIdentifier: String(describing: SelectTextCell.self))
    }
    
    // MARK: DataSource
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    func frozenRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 0
    }
    
    func frozenColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return 1
    }
    let normalWidth = SCREEN_WIDTH/3
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        switch column {
        case 0:
            return normalWidth
        case 1:
            return normalWidth + 50
        default:
            return normalWidth
        }
    }
    
    /// 记录上次计算d使用的width 相同则
    private var lastCalculateWidth: CGFloat = 0
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        //            canSelectItems.count == 0  ？ 靠左   -15  ：  -45
        let width = canSelectItems.count == 0 ? normalWidth - 15 : normalWidth - 45
        for item in items {
            if let height = item.cellHeight, width == lastCalculateWidth {
                totalHeight += height
            } else {
                var cHeight = max(item.repairItemNum.heightWithConstrainedWidth(width, font: Font(16)) + 24, item.name.heightWithConstrainedWidth(normalWidth+50, font: Font(16)) + 24)
                cHeight = max(cHeight, item.afterSaleGroupName.heightWithConstrainedWidth(normalWidth, font: Font(16)) + 24)
                cHeight = max(cHeight, item.areaNum.heightWithConstrainedWidth(normalWidth, font: Font(16)) + 24)
                let textH = max(44, cHeight)
                item.cellHeight = textH
                totalHeight += textH
            }
        }
        lastCalculateWidth = width
        return totalHeight + 35
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 44
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            switch indexPath.column {
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectHeaderCell.self), for: indexPath) as! SelectHeaderCell
                cell.label.text = header[indexPath.column]
                /// 是否全选了
                cell.isSelect = selectItems.count == canSelectItems.count
                cell.imageView.isHidden = canSelectItems.count == 0
                cell.setLabelSnpToLeft(canSelectItems.count == 0)
                return cell
            case header.count-1:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.right)
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
                cell.label.text = header[indexPath.column]
                cell.setLabelAlignment(.center)
                return cell
            }
        } else {
            let model = items[indexPath.row - 1]
            switch indexPath.column {//["项目编号","项目名称","工时","班组","工位","项目状态"]
            case 0:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: SelectTextCell.self), for: indexPath) as! SelectTextCell
                cell.isSelect = selectItems.contains(model)
                cell.isAdd = model.isAppend
                cell.imageView.isHidden = !canSelectItems.contains(model)
                cell.setLabelSnpToLeft(canSelectItems.count == 0)
                cell.label.text = model.repairItemNum
                cell.label.numberOfLines = 0
//                cell.label.textAlignment = usesLineFragmentOrigin
//                cell.label.lineBreakMode = .byCharWrapping//NSLineBreakByCharWrapping
                cell.label.textColor = model.itemState != .completed ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                return cell
            case 1,2,3,4:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.center)
                switch indexPath.column {
                case 1:
                    cell.label.text = model.name
                case 2:
                    cell.label.text = model.workingHours.toAmoutString()
                case 3:
                    cell.label.text = "\(model.afterSaleGroupName)"
                default:
                    cell.label.text = "\(model.areaNum)"
                }
                cell.label.numberOfLines = 0
                cell.label.textColor = model.itemState != .completed ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                return cell
            default:
                let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
                cell.setLabelAlignment(.right)
                cell.label.text = model.itemState.stateStr
                cell.label.numberOfLines = 0
                cell.label.textColor = model.itemState != .completed ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                return cell
            }
        }
    }
    
    /// Delegate
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            /// 全选全不选
            if selectItems.count == canSelectItems.count {
                selectItems = []
            } else {
                selectItems = canSelectItems
            }
            spreadsheetView.reloadData()
        } else {
            /// 选择取消选择
            let model = items[indexPath.row - 1]
            if canSelectItems.contains(model) {/// 可以选择的
                if let index = selectItems.firstIndex(of: model) {
                    selectItems.remove(at: index)
                    (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectTextCell)?.isSelect = false
                    (spreadsheetView.cellForItem(at: IndexPath(row: 0, column: 0)) as? SelectHeaderCell)?.isSelect = false
                } else {
                    selectItems.append(model)
                    (spreadsheetView.cellForItem(at: IndexPath(row: indexPath.row, column: 0)) as? SelectTextCell)?.isSelect = true
                    if selectItems.count == canSelectItems.count {
                        (spreadsheetView.cellForItem(at: IndexPath(row: 0, column: 0)) as? SelectHeaderCell)?.isSelect = true
                    }
                }
            } else {/// 不能选择的
                return
            }
        }
        
    }
}
