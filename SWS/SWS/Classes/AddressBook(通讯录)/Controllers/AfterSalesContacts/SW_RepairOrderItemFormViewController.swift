//
//  SW_RepairOrderItemFormViewController.swift
//  SWS
//
//  Created by jayway on 2019/3/1.
//  Copyright © 2019 yuanrui. All rights reserved.
//

import UIKit
import SpreadsheetView

class SW_RepairOrderItemFormViewController: SW_BaseFormViewController, SpreadsheetViewDataSource, SpreadsheetViewDelegate {
    var type: SW_RepairOrderFormType = .item
    var header = ["项目名称","工时","项目状态"]
    var items = [SW_RepairOrderFormBaseModel]() {
        didSet {
            if items.count > 0 {
                type = items.first?.type ?? .item
                header = type.headerArr
                spreadsheetView.isHidden = false
                let totalHeight = calculateCellHeight()
                spreadsheetView.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: max(totalHeight, SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 94 - TABBAR_BOTTOM_INTERVAL))
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(74 + TABBAR_BOTTOM_INTERVAL + spreadsheetView.frame.height))
                noDataLb.isHidden = true
            } else {
                spreadsheetView.isHidden = true
                noDataLb.isHidden = false
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: CGFloat(SCREEN_HEIGHT - NAV_TOTAL_HEIGHT - 40))
            }
            spreadsheetView.reloadData()
        }
    }
    var spreadsheetView = SpreadsheetView(frame: CGRect.zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    
    private func setup() {
        scrollView.addSubview(spreadsheetView)
        spreadsheetView.dataSource = self
        spreadsheetView.delegate = self
        spreadsheetView.bounces = false
        spreadsheetView.intercellSpacing = CGSize.zero
        spreadsheetView.gridStyle = .none
        
        spreadsheetView.register(HeaderCell.self, forCellWithReuseIdentifier: String(describing: HeaderCell.self))
        spreadsheetView.register(TextCell.self, forCellWithReuseIdentifier: String(describing: TextCell.self))
    }
    

    // MARK: DataSource
    
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return header.count
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return 1 + items.count
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, widthForColumn column: Int) -> CGFloat {
        return SCREEN_WIDTH/CGFloat(header.count)
    }
    
    /// 记录上次计算d使用的width 相同则
    private var lastCalculateWidth: CGFloat = 0
    
    /// 计算items的cell 的高度，计算出来的缓存起来
    ///
    /// - Returns: cell的总高度
    private func calculateCellHeight() -> CGFloat {
        var totalHeight: CGFloat = 0
        let width = SCREEN_WIDTH/CGFloat(header.count)
        for item in items {
            if let height = item.cellHeight, width == lastCalculateWidth {
                totalHeight += height
            } else {
                if let model = item as? SW_RepairOrderAccessoriesModel {
                    let cHeight = max(model.accessoriesNum.heightWithConstrainedWidth(width - 15, font: Font(16)) + 10, model.name.heightWithConstrainedWidth(width, font: Font(16)) + 10)
                    let textH = max(30, cHeight)
                    item.cellHeight = textH
                    totalHeight += textH
                } else if let model = item as? SW_RepairOrderBoutiquesModel {
                    let cHeight = max(model.boutiqueNum.heightWithConstrainedWidth(width - 15, font: Font(16)) + 10, model.name.heightWithConstrainedWidth(width, font: Font(16)) + 10)
                    let textH = max(30, cHeight)
                    item.cellHeight = textH
                    totalHeight += textH
                } else if let model = item as? SW_RepairPackageItemModel {
                    let cHeight = max(model.activityRepairPackageName.heightWithConstrainedWidth(width - 15, font: Font(16)) + 10, model.name.heightWithConstrainedWidth(width - 15, font: Font(16)) + 10)
                    let textH = max(30, cHeight)
                    item.cellHeight = textH
                    totalHeight += textH
                } else {
                    let textH = max(30,item.name.heightWithConstrainedWidth(width - 15, font: Font(16)) + 10)
                    item.cellHeight = textH
                    totalHeight += textH
                }
            }
        }
        lastCalculateWidth = width
        return totalHeight + 35
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, heightForRow row: Int) -> CGFloat {
        if case 0 = row {
            return 30
        } else {
            return items[row-1].cellHeight ?? 30
        }
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> Cell? {
        if case 0 = indexPath.row {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: HeaderCell.self), for: indexPath) as! HeaderCell
            cell.label.text = header[indexPath.column]
            switch indexPath.column {
            case 0:
                cell.setLabelAlignment(.left)
            case header.count - 1:
                cell.setLabelAlignment(.right)
            default:
                cell.setLabelAlignment(.center)
            }
            return cell
        } else {
            let cell = spreadsheetView.dequeueReusableCell(withReuseIdentifier: String(describing: TextCell.self), for: indexPath) as! TextCell
            cell.label.numberOfLines = 0 
            switch type {
            case .item:
                if let model = items[indexPath.row - 1] as? SW_RepairOrderItemModel {
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.name
                        cell.label.textColor = model.itemStateStr != "已完工" ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                    case 1:
                        cell.setLabelAlignment(.center)
                        cell.label.text = model.workingHours.toAmoutString()
                        cell.label.textColor = model.itemStateStr != "已完工" ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                    default:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.itemStateStr
                        cell.label.textColor = model.itemStateStr != "已完工" ?  UIColor.v2Color.lightBlack : UIColor.v2Color.lightGray
                    }
                }
            case .accessories:
                if let model = items[indexPath.row - 1] as? SW_RepairOrderAccessoriesModel {
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.accessoriesNum
                    case 1:
                        cell.setLabelAlignment(.center)
                        cell.label.text = model.name
                    case 2:
                        cell.setLabelAlignment(.center)
                        cell.label.text = model.saleCount.toAmoutString()
                    default:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.outCount.toAmoutString()
                    }
                }
            case .boutiques:
                if let model = items[indexPath.row - 1] as? SW_RepairOrderBoutiquesModel {
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.boutiqueNum
                    case 1:
                        cell.setLabelAlignment(.center)
                        cell.label.text = model.name
                    case 2:
                        cell.setLabelAlignment(.center)
                        cell.label.text = model.saleCount.toAmoutString()
                    default:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.outCount.toAmoutString()
                    }
                }
            case .other:
                if let model = items[indexPath.row - 1] as? SW_RepairOrderOtherInfoModel{
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.name
                    case 1:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.receivableAmount.toAmoutString()
                    default:
                        break
                    }
                }
            case .packages:
                if let model = items[indexPath.row - 1] as? SW_RepairPackageItemModel{
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.activityRepairPackageName
                    case 1:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.name
                    default:
                        break
                    }
                }
            case .coupons:
                if let model = items[indexPath.row - 1] as? SW_RepairOrderCouponsModel{
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.batchNo
                    case 1:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.name
                    default:
                        break
                    }
                }
            case .suggest:
                if let model = items[indexPath.row - 1] as? SW_SuggestItemInfoModel {
                    switch indexPath.column {
                    case 0:
                        cell.setLabelAlignment(.left)
                        cell.label.text = model.name
                    case 1:
                        cell.setLabelAlignment(.right)
                        cell.label.text = model.itemType.rawString
                    default:
                        break
                    }
                }
            }
            return cell
        }
    }
    
    /// Delegate
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, didSelectItemAt indexPath: IndexPath) {
    }
}

class HeaderCell: Cell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let line = UIView()
        
        line.backgroundColor = UIColor.v2Color.separator
        contentView.addSubview(line)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = UIColor.v2Color.lightGray
        label.textAlignment = .left
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        contentView.backgroundColor = .white
    }
    
    func setLabelAlignment(_ alignment: NSTextAlignment) {
        if alignment == .center {
            label.snp.remakeConstraints { (make) in
                make.top.trailing.leading.bottom.equalToSuperview()
            }
        } else if alignment == .left {
            label.snp.remakeConstraints { (make) in
                make.leading.equalTo(15)
                make.top.trailing.bottom.equalToSuperview()
            }
        } else if alignment == .right {
            label.snp.remakeConstraints { (make) in
                make.trailing.equalTo(-15)
                make.top.leading.bottom.equalToSuperview()
            }
        }
        label.textAlignment = alignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

class TextCell: Cell {
    
    let addImageView = UIImageView(image: #imageLiteral(resourceName: "work_repairmanagement_icon_add"))
    
    let delImageView = UIImageView(image: #imageLiteral(resourceName: "repairOrder_icon_delete"))
    
    var isAdd = false {
        didSet {
            addImageView.isHidden = !isAdd
        }
    }
    var isDel = false {
        didSet {
            delImageView.isHidden = !isDel
        }
    }
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.v2Color.lightBlack
        label.textAlignment = .left
        
        addImageView.isHidden = true
        contentView.addSubview(addImageView)
        addImageView.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview()
        }
        delImageView.isHidden = true
        contentView.addSubview(delImageView)
        delImageView.snp.makeConstraints { (make) in
            make.leading.equalTo(4)
            make.bottom.equalTo(-5)
        }
        
        let line = UIView()
        
        line.backgroundColor = UIColor.v2Color.separator
        contentView.addSubview(line)
        contentView.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.top.bottom.equalToSuperview()
        }
        line.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setLabelAlignment(_ alignment: NSTextAlignment) {
        if alignment == .center {
            label.snp.remakeConstraints { (make) in
                make.top.trailing.leading.bottom.equalToSuperview()
            }
        } else if alignment == .left {
            label.snp.remakeConstraints { (make) in
                make.leading.equalTo(15)
                make.top.trailing.bottom.equalToSuperview()
            }
        } else if alignment == .right {
            label.snp.remakeConstraints { (make) in
                make.trailing.equalTo(-15)
                make.top.leading.bottom.equalToSuperview()
            }
        }
        label.textAlignment = alignment
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
